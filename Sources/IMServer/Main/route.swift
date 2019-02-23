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
    
    return routes
}
