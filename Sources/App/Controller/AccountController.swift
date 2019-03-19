//
//  AccountController.swift
//  App
//
//  Created by Yiqiang Zeng on 2019/3/3.
//

import Foundation
import StORM
import Turnstile
import TurnstilePerfect

class AccountController : BaseController {
    
    override init() {
        super.init()
        
        //MARK: - 路由
        self.route.add(method: .post, uri: "\(baseRoute)/user/signin", handler: self.signIn())
        self.route.add(method: .post, uri: "\(baseRoute)/user/signout", handler: self.signOut())
        self.route.add(method: .post, uri: "\(baseRoute)/user/register", handler: self.register())
        //MARK: - 直通
        self.route_ex.append("\(baseRoute)/user/signin")
        self.route_ex.append("\(baseRoute)/user/register")
        //MARK: - 过滤
        self.rules.append(("\(baseRoute)/user/register", "password", BaseValidator.password))
    }
}

extension AccountController {
    
    //MARK: - 用户登陆
    public func signIn() -> RequestHandler {
        return { request, response in
            guard let _ = request.param(name: "username"),
                let _ = request.param(name: "password") else {
                response.callback(ResultSet.requestIllegal)
                return
            }
            let username = request.param(name: "username")!
            let password = request.param(name: "password")!
            let credential = UsernamePassword(username: username, password: password)
            do {
                try request.user.login(credentials: credential)
                guard let _ = request.user.authDetails?.account.uniqueID  else {
                    response.callback(ResultSet.serverError)
                    return
                }
                let identifier = (request.user.authDetails?.account.uniqueID)!
                let token = TurnstilePerfect.tokenStore.new(id: identifier)
                let user = User()
                let params = ["uniqueid": identifier]
                try user.find(params)
                var data = user.toDict()
                data["token"] = token
                response.callback(Result.init(code: .success, data: data))
            } catch let e as StORMError {
                print(e)
                response.callback(Result(code: .signinFailure))
            } catch {
                print(error)
                response.callback(ResultSet.serverError)
            }
        }
    }
    
    //MARK: - 用户注册
    public func register() -> RequestHandler {
        return { request, response in
            guard let _ = request.param(name: "username"),
                let _ = request.param(name: "password") else {
                    response.callback(ResultSet.requestIllegal)
                    return
            }
            let username = request.param(name: "username")!
            let password = request.param(name: "password")!
            let credential = UsernamePassword(username: username, password: password)
            do {
                try request.user.register(credentials: credential)
                //persist: true, 创建新的令牌, Token
                try request.user.login(credentials: credential, persist: true)
                guard let _ = request.user.authDetails?.sessionID  else {
                    response.callback(ResultSet.serverError)
                    return
                }
                let identifier = (request.user.authDetails?.sessionID)!
                let user = User()
                let params = ["uniqueid": identifier]
                try user.find(params)
                var data = user.toDict()
                data["token"] = identifier
                response.callback(Result.init(code: .success, data: data))
            } catch let e as AccountTakenError {
                print(e)
                response.callback(Result.init(code: .userExists))
            } catch let e as TurnstileError {
                print(e)
                response.callback(ResultSet.serverError)
            } catch {
                print(error)
                response.callback(ResultSet.serverError)
            }
        }
    }
    
    //MARK: - 用户登出
    public func signOut() -> RequestHandler {
        return { request, response in
            request.user.logout()
            response.callback(Result.init(code: .success))
        }
    }
}
