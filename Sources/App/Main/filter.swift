//
//  filter.swift
//  IMServerPackageDescription
//
//  Created by yiqiang on 2018/1/20.
//

import PerfectHTTP
import TurnstilePerfect
import PerfectRequestLogger

//MARK: - 请求过滤器
func baseRequestFilter(turnstile: TurnstilePerfect) -> [(HTTPRequestFilter, HTTPFilterPriority)] {
    var filter = [(HTTPRequestFilter, HTTPFilterPriority)]()
    //MARK: - 请求过滤器初始化
    filter.append(turnstile.requestFilter)          //请求认证
    filter.append((RequestLogger(), .high))         //请求日志
    filter.append((basePreferredFilter(), .high))   //首要响应
    return filter
}

//MARK: - 响应过滤器
func baseResponseFilter(turnstile: TurnstilePerfect) -> [(HTTPResponseFilter, HTTPFilterPriority)] {
    var filter = [(HTTPResponseFilter, HTTPFilterPriority)]()
    //MARK: - 响应过滤器初始化
    filter.append(turnstile.responseFilter)         //请求认证
    filter.append((RequestLogger(), .low))          //请求日志
    filter.append((basePreferredFilter(), .high))   //首要响应
    
    return filter
}

//MARK: - 首要过滤器
open class basePreferredFilter: HTTPRequestFilter, HTTPResponseFilter {
    
    public func filterHeaders(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
        //MARK: - 响应头配置
        response.setHeader(.accessControlAllowOrigin, value: "*")
//        //yTest
//        response.addCookie(HTTPCookie(name: "TurnstileSession",
//                                      value: "sSss7uyWmnj8aVPcL30A5A",
//            //value: "VK_hyq9whMDLs8JWphRmWA",
//            domain: nil,
//            expires: .relativeSeconds(60*60*24*365),
//            path: "/",
//            secure: nil,
//            httpOnly: true))
        
        callback(.continue)
    }
    
    public func filterBody(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
        callback(.continue)
    }
    
    public func filter(request: HTTPRequest,
                       response: HTTPResponse,
                       callback: (HTTPRequestFilterResult) -> ()) {
        //身份映射
        if let uniqueID = request.user.authDetails?.account.uniqueID {
            let user = User()
            try? user.get(uniqueID: uniqueID)
            request.scratchPad["userid"] = user.id
        } else {
            request.scratchPad.removeValue(forKey: "userid")
        }
        
        callback(.continue(request, response))
    }
}

//MARK: - 文件类型请求过滤器

//MARK: - 404响应过滤器




