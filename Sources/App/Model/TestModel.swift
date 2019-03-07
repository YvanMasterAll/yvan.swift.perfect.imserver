//
//  TestModel.swift
//  IMServerPackageDescription
//
//  Created by yiqiang on 2018/1/20.
//

import StORM
import Foundation
import PerfectLib
import PostgresStORM

class TestModel: BaseModel {
    
    //MARK: - 声明区域
    public var username: String = ""    //用户名
    public var password: String = ""    //密码
    
    override open func table() -> String {
        return "test"
    }
    
    //MARK: - 表映射
    override open func to(_ this: StORMRow) {
        super.to(this)
        username = this.data["username"] as? String ?? ""
        password = this.data["password"] as? String ?? ""
    }
    public func rows() -> [TestModel] {
        return self._rows(model: self)
    }
}

extension TestModel {
    
    //MARK: -  获取密码
    public func getPassword(username: String) throws -> String? {
        let t = TestModel()
        let params = ["username": username,
                      "status": Status.normal.value]
        try t.find(params)
        for row in t.rows() {
            return row.password
        }
        return nil
    }
}

