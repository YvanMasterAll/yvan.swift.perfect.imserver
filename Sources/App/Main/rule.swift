//
//  rule.swift
//  App
//
//  Created by Yiqiang Zeng on 2019/3/8.
//

import Foundation

//MARK: - 参数过滤规则, Rule Of Filter For Parameters
typealias Rule_FP = (String, String, BaseValidator)

//MARK: - 规则初始化
func initializeRules() -> [Rule_FP] {
    var rules: [Rule_FP] = []
    
    //MARK: - 用户模块
    rules.append(contentsOf: AccountController().rules)
    
    return rules
}
