//
//  String+Extensions.swift
//  IMServerPackageDescription
//
//  Created by yiqiang on 2018/1/20.
//

import Foundation

extension String {
    
    /// 判断性别字符串
    ///
    /// - Returns: 判断结果
    public func isgender() -> Bool {
        if self == "t" || self == "f" {
            return true
        }
        return false
    }
    
    /// 正则表达式检索字符串
    ///
    /// - Parameters:
    ///   - pattern: 正则表达式
    ///   - target: 目标字符串
    /// - Returns: 检索结果, 字符串数组
    public func regex(pattern: String, target: String) -> [String] {
        var subs = [String]()
        let regex = try! NSRegularExpression(pattern: pattern,
                                             options:[NSRegularExpression.Options.caseInsensitive])
        let results = regex.matches(in: target,
                                    options: NSRegularExpression.MatchingOptions.init(rawValue: 0),
                                    range: NSMakeRange(0, target.count))
        for result in results {
            let kTarget = target
            subs.append(kTarget.substring(Range(result.range)!.lowerBound,
                                         length: Range(result.range)!.count))
        }
        return subs
    }
}


