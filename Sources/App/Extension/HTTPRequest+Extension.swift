//
//  HTTPRequest+Extension.swift
//  App
//
//  Created by Yiqiang Zeng on 2019/3/5.
//

import Foundation
import StORM
import PerfectHTTP

extension HTTPRequest {
    
    //MARK: - 获取用户标识
    public func userid() -> Int? {
        if let uid = self.scratchPad["userid"] as? Int {
            return uid
        }
        return nil
    }
    
    //MARK: - 分页指针
    public func cursor() -> StORMCursor {
        var cursor = StORMCursor(limit: basePageLimit, offset: 0)
        if let limit =  self.param(name: "limit")?.toInt() {
            cursor.limit = limit
        }
        if let page = self.param(name: "page")?.toInt() {
            cursor.offset = (page - 1)*cursor.limit
        }
        return cursor
    }
}
