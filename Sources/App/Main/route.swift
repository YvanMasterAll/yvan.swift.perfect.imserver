//
//  route.swift
//  IMServerPackageDescription
//
//  Created by yiqiang on 2018/1/20.
//

import PerfectHTTP

//MARK: - 路由初始化
func initializeRoute() -> Routes {
    var routes: Routes = Routes()
    
    //MARK: - 测试模块
    routes.add(TestController().route)
    //MARK: - 用户模块
    routes.add(AccountController().route)
    //MARK: - 聊天模块
    routes.add(ChatController().route)
    
    return routes
}

//MARK: - Straight Routes Without Authorization
func excludeRoutes() -> [String] {
    var routes: [String] = []
    
    //MARK: - 测试模块
    routes.append(contentsOf: TestController().route_ex)
    //MARK: - 用户模块
    routes.append(contentsOf: AccountController().route_ex)
    //MARK: - 聊天模块
    routes.append(contentsOf: ChatController().route_ex)
    
    return routes
}

