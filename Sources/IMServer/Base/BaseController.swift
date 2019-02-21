//
//  BaseController.swift
//  IMServerPackageDescription
//
//  Created by yiqiang on 2018/1/20.
//

import PerfectHTTP

/// 用于接受请求并根据请求创建响应内容的句柄函数格式
public typealias RequestHandler = (HTTPRequest, HTTPResponse) -> ()

class BaseController {
    
    public lazy var route : Routes = Routes()
    
    init() {
        
    }
}

