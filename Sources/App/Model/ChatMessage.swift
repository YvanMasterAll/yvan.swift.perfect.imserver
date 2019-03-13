//
//  ChatMessage.swift
//  App
//
//  Created by Yiqiang Zeng on 2019/3/5.
//

import Foundation
import StORM
import PostgresStORM
import PerfectLib
import SwiftString

class ChatMessage: BaseModel {
    
    //MARK: - 声明区域
    var id          : String        = ""
    var dialogid    : String        = ""
    var sender      : Int           = 0
    var receiver    : Int           = 0
    var body        : String        = ""
    var type        : MessageType   = .text
    var createtime  : Date          = Date()
    var updatetime  : Date          = Date()
    var status      : Status        = .unread
    var _dialogtype : DialogType    = .single
    
    override open func table() -> String {  return "chat_message"  }
    
    //MARK: - 表映射
    override public func to(_ this: StORMRow) {
        super.to(this)
        if let v = this.data["id"]          as? String { id        = v }
        if let v = this.data["dialogid"]    as? String { dialogid  = v }
        if let v = this.data["sender"]      as? Int    { sender    = v }
        if let v = this.data["receiver"]    as? Int    { receiver  = v }
        if let v = this.data["body"]        as? String { body   = v }
        if let k = this.data["type"]        as? String,
            let v = MessageType.init(k) { type = v }
        if let v = DateUtil.getDate(this.data["createtime"] as? String)     { createtime  = v }
        if let v = DateUtil.getDate(this.data["updatetime"] as? String)     { updatetime  = v }
        if let k = this.data["status"] as? String, let v = Status.init(k)   { status = v }
    }
    public func rows() -> [ChatMessage] {
        return self._rows(model: self)
    }
}

extension ChatMessage {
    
    //MARK: - 数据映射, WebSocket
    public static func fromSocketMessage(sender: Int, data: Dictionary<String, Any>) -> ChatMessage? {
        guard let receiver = data["receiver"] as? Int else { return nil }
        guard let message = data["body"] as? String else { return nil }
        guard let k2 = data["type"] as? String,
            let type = MessageType.init(k2) else { return nil }
        guard let k3 = data["dialogtype"] as? String,
            let dialogtype = DialogType.init(k3) else { return nil }
        let chatMessage = ChatMessage.init()
        chatMessage.sender = sender
        chatMessage.receiver = receiver
        chatMessage.body = message
        chatMessage.type = type
        chatMessage._dialogtype = dialogtype
        if let dialogid = data["dialogid"] as? String {
            chatMessage.dialogid = dialogid
        }
        return chatMessage
    }
}
