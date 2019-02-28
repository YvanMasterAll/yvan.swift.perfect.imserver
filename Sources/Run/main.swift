//
//  main.swift
//  IMServerPackageDescription
//
//  Created by yiqiang on 2018/1/20.
//

import PerfectLib
import App
import StORM
import PerfectHTTPServer
import PostgresStORM
import PerfectRequestLogger

do {    
    try app().start()
} catch PerfectError.networkError(let err, let msg) {
    print("网络异常: \(err) \(msg)")
}







