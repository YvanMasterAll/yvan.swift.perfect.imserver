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
    var type            : DialogType    = .normal
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
        if let v = DateUtil.getDate(this.data["createtime"] as? String)     { createtime  = v }
        if let v = DateUtil.getDate(this.data["updatetime"] as? String)     { updatetime  = v }
        if let k = this.data["status"] as? String, let v = Status.init(k)   { status = v }
    }
    public func rows() -> [ChatDialog] {
        return self._rows(model: self)
    }
}
