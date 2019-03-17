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
        if let v = this.data["createtime"] as? String      { createtime  = Date.toDate(dateString: v) }
        if let v = this.data["updatetime"] as? String      { updatetime  = Date.toDate(dateString: v) }
        if let k = this.data["status"] as? String, let v = Status.init(k)   { status = v }
    }
    public func rows() -> [ChatParticipant] {
        return self._rows(model: self)
    }
}
