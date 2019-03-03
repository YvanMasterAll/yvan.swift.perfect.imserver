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
var baseDBUsername = ""
var baseDBPassword = ""
var baseDBName     = ""
var baseURL        = "http://192.168.1.6:8181"
var baseDomain     = ""
var baseDocument   = "webroot"

//MARK: - 用户信息
let baseNickname = "用户"

//MARK: - 枚举类型
protocol BaseType { }
public enum Gender: BaseType {      //性别
    
    case male, female
    
    public var value: String {
        switch self {
        case .male              : return "男"
        case .female            : return "女"
        }
    }
    
    init?(_ value: String) {
        switch value {
        case "男"                : self = .male
        case "女"                : self = .female
        default                 : return nil
        }
    }
}
public enum Status {                //状态
    
    case normal, delete
    
    public var value: String {
        switch self {
        case .normal             : return "正常"
        case .delete             : return "删除"
        }
    }
    
    init?(_ value: String) {
        switch value {
        case "正常"               : self = .normal
        case "删除"               : self = .delete
        default                  : return nil
        }
    }
}

//MARK: - 异常类型
public enum BaseError: Error {
    
    case invalidDigestString        //无效的加密字串
}
