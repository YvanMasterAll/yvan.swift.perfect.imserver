//
//  UserService.swift
//  App
//
//  Created by Yiqiang Zeng on 2019/3/19.
//

import Foundation
import StORM

protocol UserService: class {
    
    var userpf: UserProfile { get }
    
    //MARK: - 用户简介
    func user_profile(id: Int) throws -> [String: Any]
}
