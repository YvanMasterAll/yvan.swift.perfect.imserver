//
//  ChatService.swift
//  App
//
//  Created by Yiqiang Zeng on 2019/3/6.
//

import Foundation

protocol ChatService: class {
    
    var user: User { get }
    var participant_dialog: ChatParticipant_Dialog { get }
    
    //MARK: - 用户判断
    func user_exists(id: Int) -> Bool
    
    //MARK: - 会话判断
    func dialog_exists(id1: Int, id2: Int) -> String?
}
