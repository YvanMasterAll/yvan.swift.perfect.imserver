//
//  ChatParticipant.swift
//  App
//
//  Created by Yiqiang Zeng on 2019/3/5.
//

import Foundation
import StORM
import PostgresStORM
import PerfectLib
import SwiftString

class ChatParticipant: BaseModel {
    
    //MARK: - 声明区域
    var id          : Int       = 0
    var dialogid    : String    = ""
    var p1          : Int       = 0
    var p2          : Int       = 0
    var createtime  : Date      = Date()
    var updatetime  : Date      = Date()
    var status      : Status    = .normal
    
    override open func table() -> String {  return "chat_participant"  }
    
    //MARK: - 表映射
    override public func to(_ this: StORMRow) {
        super.to(this)
        if let v = this.data["id"]              as? Int    { id        = v }
        if let v = this.data["dialogid"]        as? String { dialogid  = v }
        if let v = this.data["p1"]              as? Int    { p1        = v }
        if let v = this.data["p2"]              as? Int    { p2        = v }
        if let v = DateUtil.getDate(this.data["createtime"] as? String)     { createtime  = v }
        if let v = DateUtil.getDate(this.data["updatetime"] as? String)     { updatetime  = v }
        if let k = this.data["status"] as? String, let v = Status.init(k)   { status = v }
    }
    public func rows() -> [ChatParticipant] {
        return self._rows(model: self)
    }
}

//MARK: - ChatParticipant Join ChatDialog
class ChatParticipant_Dialog: BaseModel {
    
    //MARK: - 声明区域
    var id              : Int        = 0
    var dialogid        : String     = ""
    var p1              : Int        = 0
    var p2              : Int        = 0
    var lastmessageid   : String     = ""
    var type            : DialogType = .normal
    var createtime      : Date      = Date()
    var updatetime      : Date      = Date()
    var status          : Status    = .normal
    
    //MARK: - 表名
    var _at             : String    = ChatParticipant().table()
    var _bt             : String    = ChatDialog().table()
    var _a              : String    = "a"
    var _b              : String    = "b"
    
    override open func table() -> String {  return "\(_at) \(_a)"
        + " left join \(_bt) \(_b)"
        + " on \(_a).dialogid = \(_b).id"
    }
    
    override func columns() -> [String]? {
        return ["\(_a).id",
                "\(_a).dialogid",
                "\(_a).p1",
                "\(_a).p2",
                "\(_b).lastmessageid",
                "\(_b).type",
                "\(_a).createtime",
                "\(_a).updatetime",
                "\(_a).status"
        ]
    }
    
    //MARK: - 表映射
    override public func to(_ this: StORMRow) {
        super.to(this)
        if let v = this.data["id"]              as? Int    { id        = v }
        if let v = this.data["dialogid"]        as? String { dialogid  = v }
        if let v = this.data["p1"]              as? Int    { p1        = v }
        if let v = this.data["p2"]              as? Int    { p2        = v }
        if let v = this.data["lastmessageid"]   as? String { lastmessageid  = v }
        if let k = this.data["type"]            as? String,
            let v = DialogType.init(k) { type = v }
        if let v = DateUtil.getDate(this.data["createtime"] as? String)     { createtime  = v }
        if let v = DateUtil.getDate(this.data["updatetime"] as? String)     { updatetime  = v }
        if let k = this.data["status"] as? String, let v = Status.init(k)   { status = v }
    }
    public func rows() -> [ChatParticipant_Dialog] {
        return self._rows(model: self)
    }
}

extension ChatParticipant_Dialog {
    
    //MARK: - 会话判断
    func exists(id1: Int, id2: Int) -> String? {
        do {
            let params = ["a.p1": "\(min(id1, id2))",
                "a.p2": "\(max(id1, id2))",
                "b.type": DialogType.normal.value,
                "a.status": Status.normal.value,
                "b.status": Status.normal.value
            ]
            try self.sfind(params)
            if self.results.cursorData.totalRecords == 1 {
                return self.dialogid
            }
        } catch {
            print("Exists error: \(error)")
        }
        return nil
    }
}
