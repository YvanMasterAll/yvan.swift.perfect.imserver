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
        if let v = this.data["createtime"] as? String  { createtime  = Date.toDate(dateString: v) }
        if let v = this.data["updatetime"] as? String  { updatetime  = Date.toDate(dateString: v) }
        if let k = this.data["status"] as? String, let v = Status.init(k)   { status = v }
    }
    public func rows() -> [ChatMessage] {
        return self._rows(model: self)
    }
    
    //MARK: - 数据字典
    override func toDict(_ offset: Int = 0) -> [String : Any] {
        var data = super.toDict(offset)
        
        switch type {
        case .image:
            data["body"] = "\(baseURL)/\(body)"
        default:
            break
        }
        
        return data
    }
}

//MARK: - 消息列表
extension ChatMessage {
    
    public func list(dialogid: String, userid: Int, cursor: StORMCursor) throws -> [[String: Any]] {
        let params = ["dialogid": dialogid]
        let order = ["createtime desc"]
        try self.sfind(params, cursor: cursor, order: order)
        if self.results.rows.count > 0 {
            let lasttime = self.rows().last!.createtime
            print(lasttime)
            let sets: [String: Any] = [
                "updatetime": Date(),
                "status": Status.read
            ]
            let params = [
                SQLConditionModel("createtime", lasttime, t: .gt),
                SQLConditionModel("dialogid", dialogid),
                SQLConditionModel("receiver", userid),
                SQLConditionModel("status", Status.unread)
            ]
            try self.supdate(sets: sets, data: params)
        }
        return self.rows().map{ $0.toDict() }
    }
}

//MARK: - 数据映射, WebSocket
extension ChatMessage {
    
    public static func fromSocketMessage(cmd: SocketCmdType,
                                         data: Dictionary<String, Any>) -> ChatMessage? {
        switch cmd {
        case .chat:
            guard let sender = data["sender"] as? Int else { return nil }
            guard let receiver = data["receiver"] as? Int else { return nil }
            guard let body = data["body"] as? String else { return nil }
            guard let k2 = data["type"] as? String,
                let type = MessageType.init(k2) else { return nil }
            guard let k3 = data["dialogtype"] as? String,
                let dialogtype = DialogType.init(k3) else { return nil }
            let chatMessage = ChatMessage.init()
            chatMessage.sender = sender
            chatMessage.receiver = receiver
            chatMessage.body = body
            chatMessage.type = type
            chatMessage._dialogtype = dialogtype
            if let dialogid = data["dialogid"] as? String {
                chatMessage.dialogid = dialogid
            }
            return chatMessage
        case .list:
            guard let sender = data["sender"] as? Int else { return nil }
            guard let receiver = data["receiver"] as? Int else { return nil }
            guard let k3 = data["dialogtype"] as? String,
                let dialogtype = DialogType.init(k3) else { return nil }
            let chatMessage = ChatMessage.init()
            chatMessage.sender = sender
            chatMessage.receiver = receiver
            chatMessage._dialogtype = dialogtype
            if let dialogid = data["dialogid"] as? String {
                chatMessage.dialogid = dialogid
            }
            return chatMessage
        case .list_dialog:
            guard let sender = data["sender"] as? Int else { return nil }
            let chatMessage = ChatMessage.init()
            if let k3 = data["dialogtype"] as? String,
                let dialogtype = DialogType.init(k3) {
                chatMessage._dialogtype = dialogtype
            }
            chatMessage.sender = sender
            return chatMessage
        default:
            return nil
        }
    }
}
