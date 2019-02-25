//
//  PostgreSQL+Extensions.swift
//  IMServer
//
//  Created by Yiqiang Zeng on 2019/2/24.
//

import Foundation
import StORM
import PerfectLogger
import PostgresStORM

//MARK: - 查询优化
extension PostgresStORM {
    
    /// 查询优化
    ///
    /// - Parameters:
    ///   - data: 查询数据
    ///   - cursor: 查询游标
    ///   - order: 查询排序
    open func find(_ data: [String: Any],
                     cursor: StORMCursor = StORMCursor(),
                     order: [String] = []) throws {
        let (conditions, params) = self.explain(data)
        do {
            try select(whereclause: conditions.joined(separator: " AND "), params: params, orderby: order, cursor: cursor)
        } catch {
            LogFile.error("Error: \(error)", logFile: "./StORMlog.txt")
            throw error
        }
    }
    open func find(_ data: [SQLConditionModel],
                   cursor: StORMCursor = StORMCursor(),
                   order: [String] = []) throws {
        let (conditions, params) = self.explain(data)
        do {
            try select(whereclause: conditions.joined(separator: " AND "), params: params, orderby: order, cursor: cursor)
        } catch {
            LogFile.error("Error: \(error)", logFile: "./StORMlog.txt")
            throw error
        }
    }
    
    
    /// 查询记录数量
    ///
    /// - Parameter data: 查询数据
    /// - Returns: 返回记录数量
    open func counts(_ data: [String: Any] = [:]) throws -> Int {
        let conditions = self.explain(data)
        var whereclause = ""
        if conditions.0.count > 0 {
            whereclause = " where \(conditions.0.joined(separator: " AND "))"
        }
        let statement = "SELECT COUNT(*) AS counter FROM \(table()) \(whereclause)"
        do {
            let getCount = try sqlRows(statement, params: conditions.1)
            var numrecords = 0
            if (getCount.first != nil) {
                numrecords = getCount.first?.data["counter"] as? Int ?? 0
            }
            return numrecords
        } catch {
            LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
            self.error = StORMError.error("\(error)")
            throw error
        }
    }
    
    /// 解析查询字典为查询解释
    ///
    /// - Parameter params: ["name": "foo", "status": [normal, cancel]]
    /// - Returns: (["name = $1","status in ($2, $3)"],["foo", "normal", "cancel"])
    fileprivate func explain(_ data: [String: Any]) -> ([String], [String]) {
        var count = 1
        var params: [String] = []
        var conditions: [String] = []
        for (key, value) in data {
            switch value {
            case let v as [Any]: //判断参数类型, 如果是数组使用in关键字
                if v.count > 0 {
                    let c = "\(key.lowercased()) in ("
                    let va: [String] = v.map() { element in
                        params.append(String(describing: TypeUtil.value(element)))
                        count += 1
                        return "$\(count-1)"
                    }
                    conditions.append("\(c)\(va.joined(separator: ", ")))")
                }
            default:
                conditions.append("\(key.lowercased()) = $\(count)")
                count += 1
                params.append(String(describing: TypeUtil.value(value)))
            }
        }
        
        return (conditions, params)
    }
    
    /// 解析查询参数为查询解释
    ///
    /// - Parameter params: 查询参数
    /// - Returns: 查询解释
    fileprivate func explain(_ data: [SQLConditionModel]) -> ([String], [String]) {
        var count = 1
        var params: [String] = []
        var conditions: [String] = []
        for model in data {
            (count, params, conditions) =
                model.explain(count: count, params: params, conditions: conditions)
        }
        return (conditions, params)
    }
}

public enum SQLConditionType {
    
    //   =      !=  <   <=  >   >=  like  in     not in
    case equal, ne, lt, le, gt, ge, like, range, noin
}

public struct SQLConditionModel {
    
    var name: String
    var value: Any
    var type: SQLConditionType = SQLConditionType.equal
    
    init(_ n: String, _ v: Any, t: SQLConditionType = .equal) {
        name = n
        value = v
        type = t
    }
    
    //MARK: - 查询解释
    func explain(count: Int, params: [String], conditions: [String]) -> (Int, [String], [String]) {
        var kCount = count
        var kParams = params
        var kConditions = conditions
        switch self.type {
        case .equal:
            kConditions.append("\(self.name.lowercased()) = $\(kCount)")
            kCount += 1
            kParams.append(String(describing: TypeUtil.value(self.value)))
        case .ne:
            kConditions.append("\(self.name.lowercased()) != $\(kCount)")
            kCount += 1
            kParams.append(String(describing: TypeUtil.value(self.value)))
        case .ge:
            kConditions.append("\(self.name.lowercased()) > $\(kCount)")
            kCount += 1
            kParams.append(String(describing: TypeUtil.value(self.value)))
        case .gt:
            kConditions.append("\(self.name.lowercased()) >= $\(kCount)")
            kCount += 1
            kParams.append(String(describing: TypeUtil.value(self.value)))
        case .le:
            kConditions.append("\(self.name.lowercased()) <= $\(kCount)")
            kCount += 1
            kParams.append(String(describing: TypeUtil.value(self.value)))
        case .lt:
            kConditions.append("\(self.name.lowercased()) < $\(kCount)")
            kCount += 1
            kParams.append(String(describing: TypeUtil.value(self.value)))
        case .like:
            kConditions.append("\(self.name.lowercased()) like $\(kCount)")
            kCount += 1
            kParams.append("%" + String(describing: TypeUtil.value(self.value)) + "%")
        case .range:
            switch self.value {
            case let v as [Any]:
                if v.count > 0 {
                    let c = "\(self.name.lowercased()) in ("
                    let va: [String] = v.map() { element in
                        kParams.append(String(describing: TypeUtil.value(element)))
                        kCount += 1
                        return "$\(kCount-1)"
                    }
                    kConditions.append("\(c)\(va.joined(separator: ", ")))")
                }
            default:
                kConditions.append("\(self.name.lowercased()) = $\(kCount)")
                kCount += 1
                kParams.append(String(describing: TypeUtil.value(self.value)))
            }
        case .noin:
            switch self.value {
            case let v as [Any]:
                if v.count > 0 {
                    let c = "\(self.name.lowercased()) not in ("
                    let va: [String] = v.map() { element in
                        kParams.append(String(describing: TypeUtil.value(element)))
                        kCount += 1
                        return "$\(kCount-1)"
                    }
                    kConditions.append("\(c)\(va.joined(separator: ", ")))")
                }
            default:
                kConditions.append("\(self.name.lowercased()) != $\(kCount)")
                kCount += 1
                kParams.append(String(describing: TypeUtil.value(self.value)))
            }
        }
        return (kCount, kParams, kConditions)
    }
}
