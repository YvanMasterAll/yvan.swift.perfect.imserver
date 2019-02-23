//
//  filter.swift
//  IMServerPackageDescription
//
//  Created by yiqiang on 2018/1/20.
//

import PerfectHTTP
import PerfectRequestLogger

//MARK: - 请求过滤器
func baseRequestFilter() -> [(HTTPRequestFilter, HTTPFilterPriority)] {
    var filter = [(HTTPRequestFilter, HTTPFilterPriority)]()
    //MARK: - 请求过滤器初始化
    filter.append((basePreferredFilter(), .high))   //首要响应
    filter.append((RequestLogger(), .high))         //请求日志
    return filter
}

//MARK: - 响应过滤器
func baseResponseFilter() -> [(HTTPResponseFilter, HTTPFilterPriority)] {
    var filter = [(HTTPResponseFilter, HTTPFilterPriority)]()
    //MARK: - 响应过滤器初始化
    filter.append((basePreferredFilter(), .high))   //首要响应
    filter.append((RequestLogger(), .low))          //请求日志
    
    return filter
}

//MARK: - 首要过滤器
open class basePreferredFilter: HTTPRequestFilter, HTTPResponseFilter {
    
    public func filterHeaders(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
        //MARK: - 响应头配置
        response.setHeader(.accessControlAllowOrigin, value: "*")
        callback(.continue)
    }
    
    public func filterBody(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
        callback(.continue)
    }
    
    public func filter(request: HTTPRequest,
                       response: HTTPResponse,
                       callback: (HTTPRequestFilterResult) -> ()) {
        //TODO: 请求预处理
        callback(.continue(request, response))
    }
}

//MARK: - 文件类型请求过滤器

//MARK: - 404响应过滤器




