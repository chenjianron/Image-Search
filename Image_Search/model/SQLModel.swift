//
//  SQLModel.swift
//  Memo_Widget
//
//  Created by wzw on 2021/6/21.
//

import Foundation

protocol SQLModelProtocol {}

// 数据库模型（一张表对应一个模型）
@objcMembers
class SQLModel: NSObject, SQLModelProtocol {


    internal var table = "SearchRecord"
    
    // 记录每个模式对应的数据表是否已经创建完毕了
    private static var verified = [String:Bool]()

    // 初始化方法
    required override init() {
        super.init()

    }

    // 返回主键字段名（如果模型主键不是id，则需要覆盖这个方法）
    func primaryKey() -> String {
        return "id"
    }

    // 忽略的属性（模型中不需要与数据库表进行映射的字段可以在这里发返回）
    func ignoredKeys() -> [String] {
        return []
    }



    // 删除指定数据（可附带条件）
    @discardableResult
    class func remove(filter: String = "",name:String = "") -> Bool {
        let db = SQLiteManager.shareManger().db
        var sql = "DELETE FROM \(name)"
        if !filter.isEmpty {
            // 添加删除条件
            sql += " WHERE \(filter)"
        }
        if db.open() {
            return db.executeUpdate(sql, withArgumentsIn:[])
        } else {
            return false
        }
    }

    // 获取数量（可附带条件）
    class func count(filter: String = "",name: String = "") -> Int {
        let db = SQLiteManager.shareManger().db
        var sql = "SELECT COUNT(*) AS count FROM \(name)"
        if !filter.isEmpty {
            // 添加查询条件
            sql += " WHERE \(filter)"
        }
        if let res = db.executeQuery(sql, withArgumentsIn: []) {
            if res.next() {
                return Int(res.int(forColumn: "count"))
            } else {
                return 0
            }
        }
        return 0
    }

    // 保存当前对象数据
    // * 如果模型主键为空或者使用该主键查不到数据则新增
    // * 否则的话则更新
//    @discardableResult
//    func save(name: String, list:LinkmanModel) -> Bool{
//        // 1、编写SQLite语句
//        let sql = "INSERT INTO \(name) (name,familyName,givenName,tel,email,address,photo) VALUES (?,?,?,?,?,?,?);"
//        // 2、执行SQLite语句
//        let db = SQLiteManager.shareManger().db
//        return db.executeUpdate(sql, withArgumentsIn: [list.name,list.familyName,list.givenName,list.tel.toJsonString() as Any,list.email.toJsonString() as Any,list.address.toJsonString() as Any,list.photo as Any])
//    }

    // 删除当天对象数据
    @discardableResult
    func delete(name: String = "") -> Bool{
        let key = primaryKey()
        let data = values()
        let db = SQLiteManager.shareManger().db
        if let rid = data[key] {
            if db.open() {
                let sql = "DELETE FROM \(name) WHERE \(primaryKey())=\(rid)"
                return db.executeUpdate(sql, withArgumentsIn: [])
            }
        }
        return false
    }

    // 通过反射获取对象所有有的属性和属性值
    internal func values() -> [String:Any] {
        var res = [String:Any]()
        let obj = Mirror(reflecting:self)
        processMirror(obj: obj, results: &res)
        getValues(obj: obj.superclassMirror, results: &res)
        return res
    }

    // 供上方方法（获取对象所有有的属性和属性值）调用
    private func getValues(obj: Mirror?, results: inout [String:Any]) {
        guard let obj = obj else { return }
        processMirror(obj: obj, results: &results)
        getValues(obj: obj.superclassMirror, results: &results)
    }

    // 供上方方法（获取对象所有有的属性和属性值）调用
    private func processMirror(obj: Mirror, results: inout [String: Any]) {
        for (_, attr) in obj.children.enumerated() {
            if let name = attr.label {
                // 忽略 table 和 db 这两个属性
                if name == "table" || name == "db" {
                    continue
                }
                // 忽略人为指定的属性
                if ignoredKeys().contains(name) ||
                    name.hasSuffix(".storage") {
                    continue
                }
                results[name] = unwrap(attr.value)
            }
        }
    }

    //将可选类型（Optional）拆包
    func unwrap(_ any:Any) -> Any {
        let mi = Mirror(reflecting: any)
        if mi.displayStyle != .optional {
            return any
        }

        if mi.children.count == 0 { return any }
        let (_, some) = mi.children.first!
        return some
    }

    // 返回新增或者修改的SQL语句
    private func getSQL(data:[String:Any], forInsert:Bool = true, name: String = "")
        -> (String, [Any]?) {
        var sql = ""
        var params:[Any]? = nil
        if forInsert {
            sql = "INSERT INTO \(name)("
        } else {
            sql = "UPDATE \(name) SET "
        }
        let pkey = primaryKey()
        var wsql = ""
        var rid:Any?
        var first = true
        for (key, val) in data {
            // 处理主键
            if pkey == key {
                if forInsert {
                    if val is Int && (val as! Int) == -1 {
                        continue
                    }
                } else {
                    wsql += " WHERE " + key + " = ?"
                    rid = val
                    continue
                }
            }
            // 设置参数
            if first && params == nil {
                params = [AnyObject]()
            }
            if forInsert {
                sql += first ? "\(key)" : ", \(key)"
                wsql += first ? " VALUES (?" : ", ?"
                params!.append(val)
            } else {
                sql += first ? "\(key) = ?" : ", \(key) = ?"
                params!.append(val)
            }
            first = false
        }
        // 生成最终的SQL
        if forInsert {
            sql += ")" + wsql + ")"
        } else if params != nil && !wsql.isEmpty {
            sql += wsql
            params!.append(rid!)
        }
        return (sql, params)
    }

    // 返回建表时每个字段的sql语句
    private func getColumnSQL(column:(key: String, value: Any)) -> String {
        let key = column.key
        let val = column.value
        var sql = "'\(key)' "
        if val is Int {
            // 如果是Int型
            sql += "INTEGER"
            if key == primaryKey() {
                sql += " PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE"
            } else {
                sql += " DEFAULT \(val)"
            }
        } else {
            // 如果是其它类型
            if val is Float || val is Double {
                sql += "REAL DEFAULT \(val)"
            } else if val is Bool {
                sql += "BOOLEAN DEFAULT " + ((val as! Bool) ? "1" : "0")
            } else if val is Date {
                sql += "DATE"
            } else if val is NSData {
                sql += "BLOB"
            } else {
                // Default to text
                sql += "TEXT"
            }
            if key == primaryKey() {
                sql += " PRIMARY KEY NOT NULL UNIQUE"
            }
        }
        return sql
    }
}

extension SQLModelProtocol where Self: SQLModel {
    // 根据完成的sql返回数据结果
    static func rowsFor(sql: String = "", name:String = "") -> [Self] {
        var result = [Self]()
        let tmp = self.init()
        let data = tmp.values()
        let db = SQLiteManager.shareManger().db
        let fsql = sql.isEmpty ? "SELECT * FROM \(name)" : sql
        if let res = db.executeQuery(fsql, withArgumentsIn: []){
            // 遍历输出结果
            while res.next() {
                let t = self.init()
                for (key, _) in data {
                    if let val = res.object(forColumn: key) {
                        t.setValue(val, forKey:key)
                    }
                }
                result.append(t)
            }
        }else{
            print("查询失败")
        }
        return result
    }

    // 根据指定条件和排序算法返回数据结果
    static func rows(filter: String = "", order: String = "",
                     limit: Int = 0,name :String = "") -> [Self] {
        var sql = "SELECT * FROM \(name)"
        if !filter.isEmpty {
            sql += " WHERE \(filter)"
        }
        if !order.isEmpty {
            sql += " ORDER BY \(order)"
        }
        if limit > 0 {
            sql += " LIMIT 0, \(limit)"
        }
        return self.rowsFor(sql:sql)
    }

}
