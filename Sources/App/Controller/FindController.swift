//
//  UserController.swift
//  App
//
//  Created by Yiqiang Zeng on 2019/3/16.
//

class FindController : BaseController {
    
    //MARK: - 声明区域
    lazy var findService: FindService = {
        return FindServiceImpl()
    }()
    
    override init() {
        super.init()
        
        //MARK: - 路由
        self.route.add(method: .post, uri: "\(baseRoute)/find/user/list", handler: self.users())
    }
}

extension FindController {
    
    //MARK: - 发现用户
    public func users() -> RequestHandler {
        return { request, response in
            do {
                let list = try self.findService.user_list(cursor: request.cursor())
                response.callback(Result(code: .success, data: list))
            } catch {
                print(error)
                response.callback(ResultSet.serverError)
            }
        }
    }
}
