//
//  ChatServiceImpl.swift
//  App
//
//  Created by Yiqiang Zeng on 2019/3/6.
//

import Foundation
import StORM

class ChatServiceImpl: ChatService {
    
    lazy var user: User = {
        return User()
    }()
    lazy var dialog_participant: ChatDialog_Participant = {
        return ChatDialog_Participant()
    }()
    lazy var message: ChatMessage = {
        return ChatMessage()
    }()
    lazy var dialog_message: ChatDialog_Message = {
        return ChatDialog_Message()
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
        return try dialog_participant.exists(id1: id1, id2: id2)
    }
    
    
    /// 消息列表
    ///
    /// - Parameters:
    ///   - dialogid: 会话标识
    ///   - userid: 用户标识
    ///   - cursor: 查询指针
    /// - Returns: 返回数据
    /// - Throws: 抛出异常
    func message_list(dialogid: String, userid: Int, cursor: StORMCursor) throws -> [[String : Any]] {
        return try message.list(dialogid: dialogid, userid: userid, cursor: cursor)
    }
    
    
    /// 会话列表
    ///
    /// - Parameters:
    ///   - id: 用户标识
    ///   - dialogtype: 会话类型
    /// - Returns: 返回数据
    func dialog_list(id: Int, dialogtype: DialogType?, cursor: StORMCursor) throws -> [[String : Any]] {
        return try dialog_message.dialogs(id: id, dialogtype: dialogtype, cursor: cursor)
    }
}
