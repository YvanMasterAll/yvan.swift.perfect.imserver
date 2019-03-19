//
//  Realm.swift
//  PerfectTurnstilePostgreSQL
//
//  Created by Jonathan Guthrie on 2016-10-17.
//
//

import Turnstile
import StORM
import PostgresStORM
import TurnstileCrypto
import TurnstilePerfect

/// The "Turnstile Realm" that holds the main routing functionality for request filters
open class BaseRealm : Realm {
    
    /// A container for the Random object fromTurnstile Crypto
    public var random: Random = URandom()
    
    public init() {}
    
    /// Used when a "Credentials" onject is passed to the authenticate function. Returns an Account object.
    open func authenticate(credentials: Credentials) throws -> Account {
        switch credentials {
        case let credentials as UsernamePassword:
            return try authenticate(credentials: credentials)
        case let credentials as AccessToken:
            return try authenticate(credentials: credentials)
        default:
            throw UnsupportedCredentialsError()
        }
    }
    
    /// Used when an "AccessToken" onject is passed to the authenticate function. Returns an Account object.
    open func authenticate(credentials: AccessToken) throws -> Account {
        let account = BaseAccount()
        let token = TurnstilePerfect.tokenStore
        do {
            try token.get(credentials.string)
            if token.check() == false {
                throw IncorrectCredentialsError()
            }
            let _ = try account.get(token.userid)
            return account
        } catch {
            throw IncorrectCredentialsError()
        }
    }
    
    /// Used when a "UsernamePassword" onject is passed to the authenticate function. Returns an Account object.
    open func authenticate(credentials: UsernamePassword) throws -> Account {
        let account = BaseAccount()
        do {
            let thisAccount = try account.get(credentials.username, credentials.password)
            return thisAccount
        } catch StORMError.noRecordFound {
            throw StORMError.noRecordFound
        } catch {
            throw IncorrectCredentialsError()
        }
    }
    
    /// Registers PasswordCredentials against the AuthRealm.
    open func register(credentials: Credentials) throws -> Account {
        let account = BaseAccount()
        let newAccount = BaseAccount()
        newAccount.id(String(random.secureToken))
        switch credentials {
        case let credentials as UsernamePassword:
            do {
                if account.exists(credentials.username) {
                    throw AccountTakenError()
                }
                newAccount.username = credentials.username
                newAccount.password = credentials.password
                do {
                    //创建账户
                    try newAccount.make()
                    //创建用户
                    let user = User()
                    user.uniqueID = newAccount.uniqueID
                    user.phone = newAccount.username
                    user.nickname = "\(baseNickname)\(String.randomLetters(10))"
                    user.signature = "个性签名"
                    user.avatar = baseAvatar
                    try user.save()
                } catch {
                    print("REGISTER ERROR: \(error)")
                }
            } catch {
                throw AccountTakenError()
            }
        default:
            throw UnsupportedCredentialsError()
        }
        return newAccount
    }
}
