//
//  TestController.swift
//  IMServerPackageDescription
//
//  Created by yiqiang on 2018/1/20.
//

import PerfectHTTP

class TestController : BaseController {
    
    /// 服务
    lazy var testService: TestService = {
        return TestServiceImpl()
    }()
    
    /// 获取密码
    public func getPassword() -> RequestHandler {
        return { request, response in
            guard let username = request.param(name: "username") else {
                do {
                    try response.setBody(json: error001)
                } catch {
                    print(error)
                }
                response.completed()
                return
            }
            let t = self.testService.getPassword(username: username)
            do {
                try response.setBody(json: t)
            } catch {
                print(error)
            }
            response.completed()
        }
    }
    
    override init() {
        super.init()
        
        //路由
        self.route.add(method: .post, uri: "\(ApiRoot)/getpassword", handler: self.getPassword())
        self.route.add(method: .get, uri: "\(ApiRoot)/getpassword", handler: self.getPassword())
    }
}
