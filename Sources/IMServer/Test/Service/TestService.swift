//
//  TestService.swift
//  IMServerPackageDescription
//
//  Created by yiqiang on 2018/1/20.
//

import Foundation
import PerfectLib

protocol TestService: class {
    
    var testModel: TestModel { get }
    
    /// 获取密码
    ///
    /// @param username: 用户名
    func getPassword(username: String) -> JSONConvertible
}

