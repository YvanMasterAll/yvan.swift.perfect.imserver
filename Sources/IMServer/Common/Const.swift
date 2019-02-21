//
//  Const.swift
//  IMServerPackageDescription
//
//  Created by yiqiang on 2018/1/20.
//

import Foundation

//接口根目录
let ApiRoot = "/api/v1"
//返回结果
struct Result {
    var code: Int
    var result: [String: Any]
    init(_ code: Int, _ result: [String: Any]) {
        self.code = code
        self.result = result
    }
    init(_ code: Int, _ msg: String) {
        self.code = code
        self.result = ["msg": msg]
    }
    func asObject() -> [String: Any] {
        return ["code": code, "result": result]
    }
}
let error001 = Result.init(99, "非法请求").asObject()
let error002 = Result.init(98, "服务端错误").asObject()

