//
//  ChatServiceImpl.swift
//  App
//
//  Created by Yiqiang Zeng on 2019/3/6.
//

import Foundation

class ChatServiceImpl: ChatService {
    
    lazy var user: User = {
        return User()
    }()
    lazy var participant_dialog: ChatDialog_Participant = {
        return ChatDialog_Participant()
    }()
    
    /// 用户判断
    ///
    /// - Parameter id: 用户标识
    func user_exists(id: Int) throws -> Bool {
        return try user.exists(id: id)
    }
    
    /// 会话判断
    ///
    /// - Parameters:
    ///   - id1: 标识1
    ///   - id2: 标识2
    /// - Returns: 返回会话标识
    func dialog_exists(id1: Int, id2: Int) throws -> String? {
        return try participant_dialog.exists(id1: id1, id2: id2)
    }
}
