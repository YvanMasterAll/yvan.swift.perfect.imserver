//
//  UserServiceImpl.swift
//  App
//
//  Created by Yiqiang Zeng on 2019/3/19.
//

import Foundation
import StORM

class UserServiceImpl: UserService {
    
    lazy var userpf: UserProfile = {
        return UserProfile()
    }()

    /// 用户简介
    ///
    /// - Parameter id: 用户标识
    func user_profile(id: Int) throws -> [String: Any] {
        return try userpf.profile(id: id)
    }
}
