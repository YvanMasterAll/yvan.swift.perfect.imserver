//
//  HTTPRequest+Extension.swift
//  App
//
//  Created by Yiqiang Zeng on 2019/3/5.
//

import Foundation
import PerfectHTTP

extension HTTPRequest {
    
    //MARK: - 获取用户标识
    public func userid() -> Int? {
        if let uid = self.scratchPad["userid"] as? Int {
            return uid
        }
        return nil
    }
}
