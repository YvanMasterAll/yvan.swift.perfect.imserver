//
//  Environment.swift
//  IMServerPackageDescription
//
//  Created by yiqiang on 2018/1/20.
//

import PostgresStORM

struct Environment {
    
    //MARK: - 环境初始化
    static func initialize() {
        if let dict = Util.fileToDict(filePath: baseConfig) {
            if let url = dict["url"] as? String {
                baseURL = url
            }
            if let domain = dict["domain"] as? String {
                baseDomain = domain
            }
            if let document = dict["document"] as? String {
                baseDocument = document
            }
            if let server_port = dict["server_port"] as? Int {
                baseServerPort = server_port
            }
            PostgresConnector.host      = dict["db_host"]     as? String ?? baseDBHost
            PostgresConnector.username  = dict["db_username"] as? String ?? baseDBUsername
            PostgresConnector.password  = dict["db_password"] as? String ?? baseDBPassword
            PostgresConnector.database  = dict["db_name"]     as? String ?? baseDBName
            PostgresConnector.port      = dict["db_port"]     as? Int    ?? baseDBPort
        }
        initializeTables()
    }
    fileprivate static func initializeTables() {
        //MARK: - 测试模块
        try? TestModel.init().setup()
    }
}
