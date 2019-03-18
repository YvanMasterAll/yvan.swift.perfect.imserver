//
//  ChatService.swift
//  App
//
//  Created by Yiqiang Zeng on 2019/3/6.
//

import Foundation
import StORM

protocol ChatService: class {
    
    var user: User { get }
    var dialog_participant: ChatDialog_Participant { get }
    
    //MARK: - 用户判断
    func user_exists(id: Int) throws -> Bool
    
    //MARK: - 会话判断
    func dialog_exists(id1: Int, id2: Int) throws -> String?
    
    //MARK: - 消息列表
    func message_list(dialogid: String, userid: Int, cursor: StORMCursor) throws -> [[String: Any]]
    
    //MARK: - 会话列表
    func dialog_list(id: Int, dialogtype: DialogType?, cursor: StORMCursor) throws -> [[String: Any]]
}
