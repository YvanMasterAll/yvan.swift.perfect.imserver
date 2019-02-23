//
//  Util.swift
//  IMServerPackageDescription
//
//  Created by yiqiang on 2018/1/20.
//

import JSONConfig
import Foundation
#if os(Linux) || os(Android) || os(FreeBSD)
import Glibc
#else
import Darwin
#endif

struct Util {
    
    /// 生成随机数
    /// - parameter min: 最小值
    /// - parameter max: 最大值
    static func randomNumber(min: Int, max: Int) -> Int {
        #if os(Linux)
        return Int((random() % (max - min + 1)) + min)
        #else
        return Int(arc4random_uniform(UInt32(max - min + 1)) + UInt32(min))
        #endif
    }
    
    //MARK: - 文件操作
    
    /// 解析Json文件为字典
    ///
    /// - Parameter filePath: 文件路径
    static func fileToDict(filePath: String) -> [String: Any]? {
        if let data = JSONConfig(name: filePath) {
            return data.getValues()
        }
        return nil
    }
}

//MARK: - 测试工具
struct UtilTest {
    
    public static func setup() {
        //Test: - 测试随机数
        for _ in 0..<10 {
            print(Util.randomNumber(min: 10, max: 20))
        }
    }
}
