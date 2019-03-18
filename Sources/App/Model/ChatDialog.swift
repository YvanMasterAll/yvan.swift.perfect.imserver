//
//  ChatDialog.swift
//  App
//
//  Created by Yiqiang Zeng on 2019/3/5.
//

import Foundation
import StORM
import PostgresStORM
import PerfectLib
import SwiftString

class ChatDialog: BaseModel {
    
    //MARK: - 声明区域
    var id              : String        = ""
    var lastmessageid   : String        = ""
    var type            : DialogType    = .single
    var createtime      : Date          = Date()
    var updatetime      : Date          = Date()
    var status          : Status        = .normal
    
    override open func table() -> String {  return "chat_dialog"  }
    
    //MARK: - 表映射
    override public func to(_ this: StORMRow) {
        super.to(this)
        if let v = this.data["id"]              as? String  { id             = v }
        if let v = this.data["lastmessageid"]   as? String  { lastmessageid  = v }
        if let k = this.data["type"]            as? String,
            let v = DialogType.init(k) { type = v }
        if let v = this.data["createtime"] as? String       { createtime  = Date.toDate(dateString: v) }
        if let v = this.data["updatetime"] as? String       { updatetime  = Date.toDate(dateString: v) }
        if let k = this.data["status"] as? String, let v = Status.init(k)   { status = v }
    }
    public func rows() -> [ChatDialog] {
        return self._rows(model: self)
    }
}

//MARK: - ChatDialog Join Participant
class ChatDialog_Participant: BaseModel {
    
    //MARK: - 声明区域
    var id        : String     = ""
    var p1              : Int        = 0
    var p2              : Int        = 0
    var lastmessageid   : String     = ""
    var type            : DialogType = .single
    var createtime      : Date      = Date()
    var updatetime      : Date      = Date()
    var status          : Status    = .normal
    
    //MARK: - 表名
    var _at             : String    = ChatDialog().table()
    var _bt             : String    = ChatParticipant().table()
    var _a              : String    = "a"
    var _b              : String    = "b"
    
    override open func table() -> String {  return "\(_at) \(_a)"
        + " left join \(_bt) \(_b)"
        + " on \(_a).id = \(_b).dialogid"
    }
    
    override func columns() -> [String]? {
        return ["\(_a).id",
            "\(_b).p1",
            "\(_b).p2",
            "\(_a).lastmessageid",
            "\(_a).type",
            "\(_a).createtime",
            "\(_a).updatetime",
            "\(_a).status"
        ]
    }
    
    //MARK: - 表映射
    override public func to(_ this: StORMRow) {
        super.to(this)
        if let v = this.data["id"]              as? String { id        = v }
        if let v = this.data["p1"]              as? Int    { p1        = v }
        if let v = this.data["p2"]              as? Int    { p2        = v }
        if let v = this.data["lastmessageid"]   as? String { lastmessageid  = v }
        if let k = this.data["type"]            as? String,
            let v = DialogType.init(k) { type = v }
        if let v = this.data["createtime"] as? String      { createtime  = Date.toDate(dateString: v) }
        if let v = this.data["updatetime"] as? String      { updatetime  = Date.toDate(dateString: v) }
        if let k = this.data["status"] as? String, let v = Status.init(k)   { status = v }
    }
    public func rows() -> [ChatDialog_Participant] {
        return self._rows(model: self)
    }
}

extension ChatDialog_Participant {
    
    //MARK: - 会话判断
    func exists(id1: Int, id2: Int) throws -> String? {
        let params = ["b.p1": "\(min(id1, id2))",
            "b.p2": "\(max(id1, id2))",
            "a.type": DialogType.single.value,
            "a.status": Status.normal.value,
            "b.status": Status.normal.value
        ]
        try self.sfind(params)
        if self.results.cursorData.totalRecords == 1 {
            return self.id
        }
        return nil
    }
}

//MARK: - ChatDialog Join Message
class ChatDialog_Message: BaseModel {
    
    //MARK: - 声明区域
    var id              : String      = ""
    var messageid       : String      = ""
    var sender          : Int         = 0
    var receiver        : Int         = 0
    var body            : String      = ""
    var avatar          : String      = ""
    var name            : String      = ""
    var type            : DialogType  = .single
    var messagetype     : MessageType = .text
    var createtime      : Date        = Date()
    var updatetime      : Date        = Date()
    var status          : Status      = .normal
    
    //MARK: - 表映射
    override public func to(_ this: StORMRow) {
        super.to(this)
        if let v = this.data["id"]              as? String { id        = v }
        if let v = this.data["messageid"]       as? String { messageid = v }
        if let v = this.data["sender"]          as? Int    { sender    = v }
        if let v = this.data["receiver"]        as? Int    { receiver  = v }
        if let v = this.data["body"]            as? String { body      = v }
        if let v = this.data["avatar"]          as? String { avatar    = v }
        if let v = this.data["name"]            as? String { name      = v }
        if let k = this.data["type"]            as? String,
            let v = DialogType.init(k) { type = v }
        if let k = this.data["messagetype"]     as? String,
            let v = MessageType.init(k) { messagetype = v }
        if let v = this.data["createtime"] as? String      { createtime  = Date.toDate(dateString: v) }
        if let v = this.data["updatetime"] as? String      { updatetime  = Date.toDate(dateString: v) }
        if let k = this.data["status"] as? String, let v = Status.init(k)   { status = v }
    }
    public func rows() -> [ChatDialog_Message] {
        return self._rows(model: self)
    }
    
    //MARK: - 私有成员
    fileprivate let _sql_dialogs_single = """
select a.id,
    b.id as messageid,
    b.sender,
    b.receiver,
    b.body,
    c.avatar,
    c.nickname as name,
    a.type,
    b.type as messagetype,
    a.createtime,
    a.updatetime,
    a.status
from chat_dialog a
left join chat_message b on a.id=b.dialogid
left join users c on b.sender=c.id
where a.lastmessageid=b.id
and a.type=$1
and b.receiver=$2
and a.status=$3
and c.status=$3
union
select a.id,
    b.id as messageid,
    b.sender,
    b.receiver,
    b.body,
    c.avatar,
    c.nickname as name,
    a.type,
    b.type as messagetype,
    a.createtime,
    a.updatetime,
    a.status
from chat_dialog a
left join chat_message b on a.id=b.dialogid
left join users c on b.receiver=c.id
where a.lastmessageid=b.id
and a.type=$1
and b.sender=$2
and a.status=$3
and c.status=$3
"""
}

extension ChatDialog_Message {
    
    //MARK: - 会话列表
    func dialogs(id: Int, dialogtype: DialogType?, cursor: StORMCursor) throws -> [[String: Any]] {
        //TODO: 会话类型判断
        let statement = _sql_dialogs_single
        let params: [Any] = [
            DialogType.single,
            "\(id)",
            Status.normal
        ]
        try self.sql_ex(statement, params: params, cursor: cursor)
        return rows().map() { return $0.toDict() }
    }
}
