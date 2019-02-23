//
//  TestController.swift
//  IMServerPackageDescription
//
//  Created by yiqiang on 2018/1/20.
//

import PerfectHTTP

class TestController : BaseController {
    
    //MARK: - 声明区域
    lazy var testService: TestService = {
        return TestServiceImpl()
    }()
    
    override init() {
        super.init()
        
        //MARK: - 路由
        self.route.add(method: .post, uri: "\(baseRoute)/getpassword", handler: self.getPassword())
        self.route.add(method: .get, uri: "\(baseRoute)/getpassword", handler: self.getPassword())
    }
}

extension TestController {
    
    //MARK: - 获取密码
    public func getPassword() -> RequestHandler {
        return { request, response in
            guard let username = request.param(name: "username") else {
                do {
                    try response.setBody(json: ResultSet.requestIllegal)
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
}
