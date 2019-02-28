//
//  BaseModel.swift
//  IMServerPackageDescription
//
//  Created by yiqiang on 2018/1/20.
//

import Foundation
import StORM
import PostgresStORM

protocol BaseModelProtocol {
    
    var createtime: Date    { get set }
    var updatetime: Date    { get set }
    var status:     Status  { get set }
}
class BaseModel: PostgresStORM, BaseModelProtocol {
    
    //MARK: - 默认字段
    var createtime: Date    = Date()
    var updatetime: Date    = Date()
    var status:     Status  = .normal
    
    required override init() {
        super.init()
    }
    
    public func _rows<T>(model: T) -> [T] where T: BaseModel {
        var rows = [T]()
        for i in 0..<model.results.rows.count {
            let row = T()
            row.to(model.results.rows[i])
            rows.append(row)
        }
        return rows
    }
    
    /// 生成数据字典
    ///
    /// - Parameter offset: 偏移量
    /// - Returns: 返回数据字典
    func toDict(_ offset: Int = 0) -> [String: Any] {
        var c = [String: Any]()
        var count = 0
        let mirror = Mirror(reflecting: self)
        for case let (label?, value) in mirror.children {
            if count >= offset && !label.hasPrefix("internal_") && !label.hasPrefix("_") {
                if value is [String:Any] {
                    c[label] = modifyValue_AfterSQL(try! (value as! [String:Any]).jsonEncodedString(), forKey: label)
                } else if value is [String] {
                    c[label] = modifyValue_AfterSQL((value as! [String]).joined(separator: ","), forKey: label)
                } else {
                    c[label] = modifyValue(value, forKey: label)
                }
            }
            count += 1
        }
        return c
    }
    
    /// 读取数据变更
    ///
    /// - Parameters:
    ///   - v: 字段值
    ///   - k: 字段
    /// - Returns: 返回变更数据
    func modifyValue_AfterSQL(_ v: Any, forKey k: String) -> Any {
        //TODO: 读取数据变更
        
        return TypeUtil.value(v)
    }
    
    /// 存储数据变更
    ///
    /// - Parameters:
    ///   - v: 字段值
    ///   - k: 字段
    /// - Returns: 返回变更数据
    override func modifyValue(_ v: Any, forKey k: String) -> Any {
        //TODO: 存储数据变更
        
        return TypeUtil.value(v)
    }
}
