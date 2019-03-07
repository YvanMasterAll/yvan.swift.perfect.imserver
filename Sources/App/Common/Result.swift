//
//  Result.swift
//  IMServer
//
//  Created by Yiqiang Zeng on 2019/2/25.
//

import Foundation

//MARK: - 响应信息
struct Result {
    
    init(code: ResultCode) {
        self.code = code
    }
    init(code: ResultCode, msg: String) {
        self.code = code
        self.msg = msg
    }
    init(code: ResultCode, data: [Any]) {
        self.code = code
        self.dataArray = data
    }
    init(code: ResultCode, data: [String: Any]) {
        self.code = code
        self.dataDict = data
    }
    init(code: ResultCode, msg: String, data: [Any]) {
        self.code = code
        self.msg = msg
        self.dataArray = data
    }
    init(code: ResultCode, msg: String, data: [String: Any]) {
        self.code = code
        self.msg = msg
        self.dataDict = data
    }
    
    func toDict() -> [String: Any] {
        var dict = [String: Any]()
        dict["code"] = code.value()
        dict["msg"] = msg ?? code.msg()
        dict["dataArray"] = dataArray
        dict["dataDict"] = dataDict
        return dict
    }
    
    fileprivate var code: ResultCode!
    fileprivate var msg: String?
    fileprivate var dataArray: [Any]?
    fileprivate var dataDict: [String: Any]?
}
struct ResultSet {
    
    static let requestIllegal  = Result.init(code: .requestIllegal)
    static let serverError     = Result.init(code: .serverError)
    static let unknown         = Result.init(code: .unknown)
}
enum ResultCode: Int {
    
    //MARK: - 200
    case success            = 200
    
    //MARK: - 400
    case requestIllegal     = 401
    case failure            = 499
    case userExists         = 411
    case userNotExists      = 412
    case signinFailure      = 413
    
    //MARK: - 500
    case serverError        = 500
    
    //MARK: - 900
    case unknown            = 900
    
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
        case .userExists:       return "用户已存在"
        case .userNotExists:    return "用户不存在"
        case .signinFailure:    return "登陆失败"
        //MARK: - 500
        case .serverError:      return "服务器异常"
        //MARK: - 900
        case .unknown:          return "未知错误"
        }
    }
}
