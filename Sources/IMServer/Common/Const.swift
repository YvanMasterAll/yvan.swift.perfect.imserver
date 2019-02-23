//
//  Const.swift
//  IMServerPackageDescription
//
//  Created by yiqiang on 2018/1/20.
//

import Foundation

//MARK: - 根路由
let baseRoute = "/api/v1"

//MARK: - 日志文件
let baseLog = "./log/request.log"

//MARK: - 配置文件
let baseConfig = "./config/ApplicationConfiguration.json"

//MARK: - 默认配置
var baseDBHost     = "localhost"
var baseServerPort = 8181
var baseDBPort     = 5432
var baseDBUsername = "postgres"
var baseDBPassword = "19920213"
var baseDBName     = "postgres"
var baseURL        = "http://192.168.1.3:8181"
var baseDomain     = ""
var baseDocument   = "webroot"

//MARK: - 响应信息
struct Result {

    init(_ code: ResultCode) {
        self.code = code
    }
    init(_ code: ResultCode, _ msg: String) {
        self.code = code
        self.msg = msg
    }
    init(_ code: ResultCode, _ result: [String: Any]) {
        self.code = code
        self.result = result
    }
    init(_ code: ResultCode, _ msg: String, _ result: [String: Any]) {
        self.code = code
        self.msg = msg
        self.result = result
    }
    
    func toDict() -> [String: Any] {
        var dict = [String: Any]()
        dict["code"] = code.value()
        dict["code"] = msg ?? code.msg()
        dict["result"] = result ?? [String: Any]()
        return dict
    }
    
    fileprivate var code: ResultCode!
    fileprivate var msg: String?
    fileprivate var result: [String: Any]?
}
struct ResultSet {
    
    static let requestIllegal  = Result.init(.requestIllegal, "非法请求").toDict()
    static let serverError     = Result.init(.serverError, "服务端错误").toDict()
}
enum ResultCode: Int {
    
    //MARK: - 200
    case success            = 200
    
    //MARK: - 400
    case requestIllegal     = 401
    case failure            = 499
    
    //MARK: - 500
    case serverError        = 500
    
    func value() -> Int {
        return self.rawValue
    }
    
    func msg() -> String {
        switch self {
        //MARK: - 200
        case .success:          return "请求成功"
        //MARK: - 400
        case .requestIllegal:   return "非法请求"
        case .failure:          return "请求失败"
        //MARK: - 500
        case .serverError:      return "服务器异常"
        }
    }
}

