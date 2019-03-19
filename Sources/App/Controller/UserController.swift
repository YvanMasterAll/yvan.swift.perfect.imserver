//
//  UserController.swift
//  App
//
//  Created by Yiqiang Zeng on 2019/3/19.
//

import Foundation
import StORM
import Turnstile
import TurnstilePerfect

class UserController : BaseController {
    
    //MARK: - 声明区域
    lazy var userService: UserService = {
        return UserServiceImpl()
    }()
    
    override init() {
        super.init()
        
        //MARK: - 路由
        self.route.add(method: .post, uri: "\(baseRoute)/user/profile", handler: self.profile())
    }
}

extension UserController {
    
    //MARK: - 用户简介
    public func profile() -> RequestHandler {
        return { request, response in
            guard let id = request.param(name: "id")?.toInt() else {
                response.callback(ResultSet.requestIllegal)
                return
            }
            do {
                let data = try self.userService.user_profile(id: id)
                return response.callback(Result(code: .success, data: data))
            } catch {
                response.callback(ResultSet.serverError)
            }
        }
    }
}

