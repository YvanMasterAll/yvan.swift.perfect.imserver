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
        self.route.add(method: .post, uri: "\(baseRoute)/test/getpassword", handler: self.getPassword())
        self.route.add(method: .get, uri: "\(baseRoute)/test/getpassword", handler: self.getPassword())
    }
}

extension TestController {
    
    //MARK: - 获取密码
    public func getPassword() -> RequestHandler {
        return { request, response in
            guard let username = request.param(name: "username") else {
                response.callback(ResultSet.requestIllegal)
                return
            }
            do {
                var result = Result.init(code: .failure, msg: "未找到密码")
                if let data = try self.testService.getPassword(username: username) {
                    result = Result.init(code: .success, data: [data])
                }
                response.callback(result)
            } catch {
                print(error)
                response.callback(ResultSet.serverError)
            }
        }
    }
}
