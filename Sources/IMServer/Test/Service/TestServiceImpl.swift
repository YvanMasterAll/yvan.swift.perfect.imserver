//
//  TestServiceImpl.swift
//  IMServerPackageDescription
//
//  Created by yiqiang on 2018/1/20.
//

import Foundation
import PerfectLib

class TestServiceImpl: TestService {
    
    lazy var testModel: TestModel = {
        return TestModel()
    }()
    
    /// 获取密码
    ///
    /// - Parameter username: 用户名
    func getPassword(username: String) -> JSONConvertible {
        return self.testModel.getPassword(username: username)
    }
}
