//
//  SQL.swift
//  Image_Search
//
//  Created by GC on 2021/8/17.
//

import Foundation

class SQL {
    
    static var dformatter:DateFormatter = {
        let dformatter = DateFormatter()
        dformatter.dateFormat = "MM-dd hh:mm:ss"
        return dformatter
    }()
    
    static func createTable() {
        
        // 编写SQL语句（id: 主键  name和age是字段名）
        let sql = "CREATE TABLE IF NOT EXISTS SearchRecord( \n" +
            "id INTEGER PRIMARY KEY AUTOINCREMENT, \n" +
            "image blob, \n" +
            "keyword text, \n" +
            "date text \n" +
            "); \n"
        
        // 执行SQL语句（注意点: 在FMDB中除了查询意外, 都称之为更新）
        let db = SQLiteManager.shareManger().db
        if db.open() {
            if db.executeUpdate(sql, withArgumentsIn: []){
                print("创建表成功")
            }else{
                print("创建表失败")
            }
        }
        db.close()
    }
    
    static func insert(imagedata:Data = Data(),keyword:String = ""){
        let sql = "INSERT INTO SearchRecord (image,keyword,date) VALUES (?,?,?);"
        // 执行SQL语句
        let db = SQLiteManager.shareManger().db
        if db.open() {
            if db.executeUpdate(sql, withArgumentsIn: [ imagedata,keyword, dformatter.string(from: Date())]){
                print("插入成功")
            } else {
                print("插入失败")
            }
        }
    }
    
    static func delete(id:Int){
        // 编写SQL语句
        let sql = "DELETE FROM SearchRecord WHERE id = ?;"
        // 执行SQL语句
        let db = SQLiteManager.shareManger().db
        if db.open() {
            if db.executeUpdate(sql, withArgumentsIn: [id]){
                print("删除成功")
            }else{
                print("删除失败")
            }
        }
    }
    static func deleteAll() -> Bool{
        // 编写SQL语句
        let sql = "DELETE FROM SearchRecord;"
        // 执行SQL语句
        let db = SQLiteManager.shareManger().db
        if db.open() {
            if db.executeUpdate(sql, withArgumentsIn: []){
                print("删除成功")
                return true
            }else{
                print("删除失败")
                return false
            }
        }
        return false
    }
    
    static func find(resourceData:inout [SearchRecord]){
        // 编写SQL语句
        let sql = "SELECT * FROM SearchRecord order by id desc"
        //执行SQL语句
        let db = SQLiteManager.shareManger().db
//        var resourceData = [SearchRecord]()
        if db.open() {
            if let res = db.executeQuery(sql, withArgumentsIn: []){
                // 遍历输出结果
                while res.next() {
                    let id = res.int(forColumn: "id")
                    let image = res.data(forColumn: "image")
                    let keyword = res.string(forColumn: "keyword")
                    let date = res.string(forColumn: "date")
                    resourceData.append(SearchRecord(id: Int(id), image: image ?? Data(), keyword: keyword!, date: date!))
                }
            } else {
                print("查询失败")
            }
        }
    }
}
