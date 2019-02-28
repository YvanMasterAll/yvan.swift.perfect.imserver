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
    /// - parameter min: 最小值, 包含最小值
    /// - parameter max: 最大值, 包含最大值
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
struct TestUtil {
    
    public static func setup() {
        
        //self.test_RandomNumber()
    }
    
    //MAKR: - 测试随机数生成
    fileprivate static func test_RandomNumber() {
        for _ in 0..<10 {
            print(Util.randomNumber(min: 10, max: 20))
        }
    }
}


//MARK: - 日期工具
public class DateUtil {
    
    static func getFormat(format: String = "yyyy-MM-dd hh:mm:ss") -> DateFormatter {
        let df = DateFormatter()
        df.dateFormat = format
        df.locale = Locale.current
        return df
    }
    
    static func getDate(_ ds: String?, format: String = "yyyy-MM-dd hh:mm:ss") -> Date? {
        guard let d = ds else {
            return nil
        }
        return getFormat(format: format).date(from: d)
    }
    
    static func getString(from date: Date?) -> String {
        guard let d = date else {
            return "bad date format."
        }
        return getFormat().string(from: d)
    }
    
    static func getCurrentTime() -> String {
        return getFormat().string(from: Date())
    }
}

//MARK: - 类型工具
public class TypeUtil {
    
    /// 判断枚举类型并返回枚举值, 判断日期类型, 返回日期值, [yyyy-MM-dd hh:mm:ss]
    ///
    /// - Parameter value: 传入对象
    /// - Returns: 若传入对象非类型, 返回自身
    public static func value(_ type: Any) -> Any {
        switch type {
        case let kType as Gender       : return kType.value
        case let kType as Date         : return DateUtil.getString(from: kType)
        default                         : return type
        }
    }
}
