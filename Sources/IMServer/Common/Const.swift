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

//MARK: - 枚举类型
protocol BaseType { }

public enum Gender: BaseType {      //s性别
    
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

