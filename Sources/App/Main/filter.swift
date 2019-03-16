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
    filter.append((parameterFilter(rules:           //参数过滤
        initializeRules()), .high))
    filter.append((authenticationFilter(), .high))  //认证过滤
    filter.append((basePreferredFilter(), .high))   //偏好过滤
    
    return filter
}

//MARK: - 响应过滤器
func baseResponseFilter(turnstile: TurnstilePerfect) -> [(HTTPResponseFilter, HTTPFilterPriority)] {
    var filter = [(HTTPResponseFilter, HTTPFilterPriority)]()
    //MARK: - 响应过滤器初始化
    filter.append(turnstile.responseFilter)         //请求认证
    filter.append((RequestLogger(), .low))          //请求日志
    filter.append((basePreferredFilter(), .high))   //偏好过滤
    
    return filter
}

//MARK: - 认证过滤
func authenticationFilter() -> HTTPRequestFilter {
    var config = AuthenticationConfig.init()
    config.include("/*")
    config.exclude(excludeRoutes())
    return AuthenticationFilter(config)
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

//MARK: - 参数过滤器
open class parameterFilter: HTTPRequestFilter, HTTPResponseFilter {
    
    //MARK: - 过滤规则
    let rules: [Rule_FP]
    
    init(rules: [Rule_FP]) {
        self.rules = rules
    }
    
    public func filterHeaders(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
        callback(.continue)
    }
    
    public func filterBody(response: HTTPResponse, callback: (HTTPResponseFilterResult) -> ()) {
        callback(.continue)
    }
    
    public func filter(request: HTTPRequest,
                       response: HTTPResponse,
                       callback: (HTTPRequestFilterResult) -> ()) {
        //参数过滤
        for rule in rules {
            if rule.0 == request.path {
                if let param = request.param(name: "\(rule.1)") {
                    guard rule.2.validate(param) else {
                        response.callback(Result(code: .requestIllegal))
                        return
                    }
                }
            }
        }
        callback(.continue(request, response))
    }
}

//TODO: - 文件类型请求过滤器

//TODO: - 404响应过滤器





