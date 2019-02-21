//
//  TestModel.swift
//  IMServerPackageDescription
//
//  Created by yiqiang on 2018/1/20.
//

import Turnstile
import TurnstileCrypto
import PostgresStORM
import StORM
import PerfectLib

class TestModel: BaseModel {
    
    /// 用户名
    public var username: String = ""
    
    /// 密码
    public var password: String = ""
    
    /// 表名
    override open func table() -> String {
        return "users"
    }
    
    /// 表映射
    override open func to(_ this: StORMRow) {
        username = this.data["username"] as? String ?? ""
        password = this.data["password"] as? String ?? ""
    }
    
    /// 映射方法
    public func rows() -> [TestModel] {
        var rows = [TestModel]()
        for i in 0..<self.results.rows.count {
            let row = TestModel()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    /// 获取密码
    public func getPassword(username: String) -> JSONConvertible {
        let t = TestModel()
        
        try? t.find([("username", username)])
        
        for row in t.rows() {
            return Result.init(0, row.password).asObject()
        }

        return Result.init(1, "未找到密码").asObject()
    }
    
    /// 转换格式
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

