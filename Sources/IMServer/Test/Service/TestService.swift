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
    
    //MARK: - 获取密码
    func getPassword(username: String) -> JSONConvertible
}

