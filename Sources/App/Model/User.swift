//
//  User.swift
//  App
//
//  Created by Bedawn on 2018/1/20.
//

import Foundation
import StORM
import PostgresStORM
import PerfectLib
import SwiftString

class User: BaseModel {
    
    //MARK: - 声明区域
    var id          : Int    = 0
    var uniqueID    : String = ""
    var nickname    : String = ""
    var realname    : String = ""
    var age         : Int    = 0
    var avatar      : String = ""
    var signature   : String = ""
    var phone       : String = ""
    var email       : String = ""
    var address     : String = ""
    var college     : String = ""
    var gender      : Gender = Gender.male
    var createtime  : Date   = Date()
    var updatetime  : Date   = Date()
    var status      : Status = .normal
    
    override open func table() -> String {  return "users"  }
    
    //MARK: - 表映射
    override public func to(_ this: StORMRow) {
        super.to(this)
        if let v = this.data["id"]          as? Int    { id        = v }
        if let v = this.data["uniqueID"]    as? String { uniqueID  = v }
        if let v = this.data["nickname"]    as? String { nickname  = v }
        if let v = this.data["realname"]    as? String { realname  = v }
        if let v = this.data["age"]         as? Int    { age       = v }
        if let v = this.data["avatar"]      as? String { avatar    = v }
        if let v = this.data["signature"]   as? String { signature = v }
        if let v = this.data["phone"]       as? String { phone     = v }
        if let v = this.data["email"]       as? String { email     = v }
        if let v = this.data["address"]     as? String { address   = v }
        if let v = this.data["college"]     as? String { college   = v }
        if let k = this.data["gender"] as? String,
            let v = Gender.init(k) { gender = v }
        if let v = DateUtil.getDate(this.data["createtime"] as? String)     { createtime  = v }
        if let v = DateUtil.getDate(this.data["updatetime"] as? String)     { updatetime  = v }
        if let k = this.data["status"] as? String, let v = Status.init(k)   { status = v }
    }
    public func rows() -> [User] {
        return self._rows(model: self)
    }
}

extension User {
    
    //MARK: - 查询用户
    func get(uniqueID uid: String) throws {
        try select(whereclause: " uniqueID = $1 ", params: [uid], orderby: [])
    }
    
    //MARK: - 用户判断
    func exists(id: Int) throws -> Bool {
        let params = ["id": "\(id)",
            "status": Status.normal.value
        ]
        let count = try self.count(params)
        if count == 1 {
            return true
        }
        return false
    }
}

