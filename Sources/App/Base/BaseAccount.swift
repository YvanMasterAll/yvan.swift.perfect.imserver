//
//  BaseAccount.swift
//  App
//
//  Created by Yiqiang Zeng on 2019/3/3.
//

import Foundation
import Turnstile
import TurnstileCrypto
import TurnstilePerfect
import PostgresStORM
import StORM
import PerfectLib

/// Provides the Account structure for Perfect Turnstile
class BaseAccount : BaseModel, Account, JSONConvertible {
    
    /// The User account's Unique ID
    public var uniqueID         : String    = ""
    
    /// The username with which the user will log in with
    public var username         : String    = ""
    
    /// The password to be set for the user
    public var password         : String    = ""
    
    /// Internal container variable for the current Token object
    public var internal_token   : BaseTokenStore = BaseTokenStore()
    
    // create time
    public var createtime       : Date      = Date()
    
    // update time
    public var updatetime       : Date      = Date()
    
    // account status
    public var status           : Status    = .normal
    
    /// The table to store the data
    override open func table() -> String {
        return "account"
    }
    
    /// Shortcut to store the id
    public func id(_ newid: String) {
        uniqueID = newid
    }
    
    /// Set incoming data from database to object
    override open func to(_ this: StORMRow) {
        super.to(this)
        uniqueID    = this.data["uniqueid"] as? String ?? ""
        username    = this.data["username"] as? String ?? ""
        password    = this.data["password"] as? String ?? ""
    }
    
    /// Iterate through rows and set to object data
    public func rows() -> [BaseAccount] {
        return self._rows(model: self)
    }
}

extension BaseAccount {
    
    /// Forces a create with a hashed password
    func make() throws {
        do {
            //哈希加密
            if let k = password.digest(.sha1)?.encode(.hex),
                let v = String(validatingUTF8: k) {
                password = v
            } else {
                throw BaseError.invalidDigestString
            }
            //password = BCrypt.hash(password: password) //速度太慢, 舍弃
            //创建时间
            createtime = Date()

            try create() // can't use save as the id is populated
        } catch {
            print(error)
            throw error
        }
    }
    
    /// Performs a find on supplied username, and matches hashed password
    open func get(_ un: String, _ pw: String) throws -> BaseAccount {
        let cursor = StORMCursor(limit: 1, offset: 0)
        do {
            //查询用户
            try select(whereclause: "username = $1", params: [un], orderby: [], cursor: cursor)
            if self.results.rows.count == 0 {
                throw StORMError.noRecordFound
            }
            to(self.results.rows[0])
        } catch {
            print(error)
            throw StORMError.noRecordFound
        }
        //验证用户
        if let k = pw.digest(.sha1)?.encode(.hex),
            let v = String(validatingUTF8: k),
            password == v {
            return self
        } else {
            throw StORMError.noRecordFound
        }
    }
    
    /// Performs a find on supplied username
    open func get(_ un: String) throws -> BaseAccount {
        let cursor = StORMCursor(limit: 1, offset: 0)
        do {
            try select(whereclause: "uniqueid = $1", params: [un], orderby: [], cursor: cursor)
            if self.results.rows.count == 0 {
                throw StORMError.noRecordFound
            }
            to(self.results.rows[0])
        } catch {
            print(error)
            throw StORMError.noRecordFound
        }
        return self
    }
    
    /// Returns a true / false depending on if the username exits in the database.
    func exists(_ un: String) -> Bool {
        do {
            try select(whereclause: "username = $1", params: [un], orderby: [], cursor: StORMCursor(limit: 1, offset: 0))
            if results.rows.count == 1 {
                return true
            } else {
                return false
            }
        } catch {
            print("Exists error: \(error)")
            return false
        }
    }
    
    //MARK: - JSONConvertible
    public func jsonEncodedString() throws -> String {
        return try getJSONValues().jsonEncodedString()
    }
    public func getJSONValues() -> [String: Any] {
        return [
            "username": self.username
        ]
    }
    public func getJsonArray() -> [String] {
        var jsonArray = [String]()
        for item in self.rows() {
            try? jsonArray.append(item.jsonEncodedString())
        }
        return jsonArray
    }
}

extension BaseAccount {
    
    //MARK: - 重设密码
    public func resetPassword(_ auth: Account, _ password: String) throws {
        let p: [String: Any] = [
            "uniqueid": auth.uniqueID
        ]
        try self.find(p)
        self.password = BCrypt.hash(password: password)
        try self.save()
    }
}

