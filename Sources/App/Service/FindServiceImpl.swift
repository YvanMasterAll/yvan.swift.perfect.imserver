//
//  FindServiceImpl.swift
//  App
//
//  Created by Yiqiang Zeng on 2019/3/16.
//

import Foundation
import StORM

class FindServiceImpl: FindService {
    
    lazy var user: User = {
        return User()
    }()
    
    /// 用户列表
    ///
    /// - Parameter cursor: 查询指针
    /// - Returns: 返回数据
    /// - Throws: 抛出异常
    func user_list(cursor: StORMCursor) throws -> [[String : Any]] {
        return try user.list(cursor: cursor)
    }
}
