//
//  TestModel.swift
//  IMServerPackageDescription
//
//  Created by yiqiang on 2018/1/20.
//

import StORM
import PerfectLib
import PostgresStORM

class TestModel: BaseModel {
    
    //MARK: - 声明区域
    public var username: String = ""    //用户名
    public var password: String = ""    //密码
    
    override open func table() -> String {
        return "users"
    }
    
    //MARK: - 表映射
    override open func to(_ this: StORMRow) {
        username = this.data["username"] as? String ?? ""
        password = this.data["password"] as? String ?? ""
    }
    public func rows() -> [TestModel] {
        var rows = [TestModel]()
        for i in 0..<self.results.rows.count {
            let row = TestModel()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    func asObject() -> [[String: Any]] {
        var entries = [[String: Any]]()
        for row in rows() {
            var r = [String: Any]()
            r["username"]   = row.username
            r["password"]   = row.password
            entries.append(r)
        }
        return entries
    }
}

extension TestModel {
    
    //MARK: -  获取密码
    public func getPassword(username: String) throws -> String? {
        let t = TestModel()
        try t.find([("username", username)])
        for row in t.rows() {
            return row.password
        }
        return nil
    }
}

