//
//  FindService.swift
//  App
//
//  Created by Yiqiang Zeng on 2019/3/16.
//

import Foundation
import StORM

protocol FindService: class {
    
    var user: User { get }
    
    //MARK: - 用户列表
    func user_list(cursor: StORMCursor) throws -> [[String: Any]]
}

