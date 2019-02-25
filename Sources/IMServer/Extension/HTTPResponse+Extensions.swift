//
//  HTTPResponse+Extension.swift
//  IMServer
//
//  Created by Yiqiang Zeng on 2019/2/24.
//

import Foundation
import PerfectHTTP

extension HTTPResponse {
    
    //MARK: - 响应数据
    func callback(_ result: Result) {
        do {
            setHeader(.contentType, value: "application/json")
            try setBody(json: result.toDict())
            completed(status: .ok)
        } catch {
            print(error)
            completed(status: .internalServerError)
        }
    }
}


