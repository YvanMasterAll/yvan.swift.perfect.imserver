//
//  Curl.swift
//  AppTests
//
//  Created by Yiqiang Zeng on 2019/2/26.
//

import Foundation
import PerfectCURL
import PerfectHTTP

class CurlHelper {
    
    //MARK: - 单例
    static let instance = CurlHelper()
    private init() {}
    
    /// 网络请求
    ///
    /// - Parameters:
    ///   - url: 网络地址
    ///   - method: 请求方法
    ///   - cookie: cookies, "name1=value1; name2=value2"
    ///   - fields: fields
    ///   - completion: 回调方法
    func request(url: String,
                 method: CURLRequest.HTTPMethod,
                 cookie: String?,
                 fields: [CURLRequest.POSTField]?,
                 completion: (([String: Any]?, Bool, String?, Int) -> ())?) {
        options.append(.httpMethod(method))
        options.append(.url(url))
        if let _ = cookie { options.append(.cookie(cookie!)) }
        if let kFields = fields { kFields.forEach { options.append(.postField($0)) }}
        CURLRequest(url).perform { confirmation in
            do {
                let response = try confirmation()
                completion?(response.bodyJSON, true, nil, response.responseCode)
            } catch let error as CURLResponse.Error {
                completion?(nil, false, "Failed: response code \(error.response.responseCode)", error.response.responseCode)
            } catch {
                completion?(nil, false, "Fatal error \(error)", 500)
            }
        }
    }
    
    //MARK: - 私有成员
    fileprivate var options: [CURLRequest.Option] = []
}

