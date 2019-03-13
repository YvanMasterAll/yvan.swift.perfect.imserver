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
    
    /// 查询字段
    ///
    /// - Returns: 字段集合, 默认返回nil, 表示查询所有
    @objc open func columns() -> [String]? {
        return nil
    }
    
    /// 查询优化
    ///
    /// - Parameters:
    ///   - data: 查询数据
    ///   - cursor: 查询游标
    ///   - order: 查询排序
    open func sfind(_ data: [String: Any],
                     cursor: StORMCursor = StORMCursor(),
                     order: [String] = []) throws {
        let (conditions, params) = self.explain(data)
        do {
            if let columns = columns() {
                try select_ex(columns: columns, whereclause: conditions.joined(separator: " AND "), params: params, orderby: order, cursor: cursor, joins: [], having: [], groupBy: [])
            } else {
                try select(whereclause: conditions.joined(separator: " AND "), params: params, orderby: order, cursor: cursor)
            }
        } catch {
            LogFile.error("Error: \(error)", logFile: "./StORMlog.txt")
            throw error
        }
    }
    open func sfind(_ data: [SQLConditionModel],
                   cursor: StORMCursor = StORMCursor(),
                   order: [String] = []) throws {
        let (conditions, params) = self.explain(data)
        do {
            if let columns = columns() {
                try select_ex(columns: columns, whereclause: conditions.joined(separator: " AND "), params: params, orderby: order, cursor: cursor, joins: [], having: [], groupBy: [])
            } else {
                try select(whereclause: conditions.joined(separator: " AND "), params: params, orderby: order, cursor: cursor)
            }
        } catch {
            LogFile.error("Error: \(error)", logFile: "./StORMlog.txt")
            throw error
        }
    }
    
    /// 查询记录数量
    ///
    /// - Parameter data: 查询数据
    /// - Returns: 返回记录数量
    open func count(_ data: [String: Any] = [:]) throws -> Int {
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

extension PostgresStORM {
    
    /// 事务处理
    ///
    /// - Parameter closure: 数据库操作
    /// - Returns: 返回结果
    /// - Throws: 抛出异常
    public static func doWithTransaction<T>(closure: () throws -> T) throws -> T {
        let thisConnection = PostgresConnect(
            host:        PostgresConnector.host,
            username:    PostgresConnector.username,
            password:    PostgresConnector.password,
            database:    PostgresConnector.database,
            port:        PostgresConnector.port
        )
        thisConnection.open()
        let result = try thisConnection.server.doWithTransaction(closure: closure)
        thisConnection.server.close()
        return result
    }
    
    
    /// SQL查询, Select, 扩展方法
    ///
    /// - Parameters:
    ///   - columns: ["表名.\"字段\""]
    ///   - whereclause: 条件
    ///   - params: 参数
    ///   - orderby: 顺序
    ///   - cursor: 指针
    ///   - joins: []
    ///   - having: []
    ///   - groupBy: []
    /// - Throws: 抛出异常
    public func select_ex(
        columns:        [String],
        whereclause:    String,
        params:            [Any],
        orderby:        [String],
        cursor:            StORMCursor = StORMCursor(),
        joins:            [StORMDataSourceJoin] = [],
        having:            [String] = [],
        groupBy:        [String] = []
        ) throws {
        
        let clauseCount = "COUNT(*) AS counter"
        var clauseSelectList = "*"
        var clauseWhere = ""
        var clauseOrder = ""
        
        if columns.count > 0 {
            clauseSelectList = columns.map { column -> String in
                let k = column.split(".")
                if k.count == 2 {
                    return "\(k[0]).\"\(k[1])\""
                }
                return k[0]
                }.joined(separator: ",")
            //clauseSelectList = "\""+columns.joined(separator: "\",\"")+"\""
        } else {
            var keys = [String]()
            for i in cols() {
                keys.append(i.0)
            }
            clauseSelectList = "\""+keys.joined(separator: "\",\"")+"\""
        }
        if whereclause.count > 0 {
            clauseWhere = " WHERE \(whereclause)"
        }
        
        var paramsString = [String]()
        for i in 0..<params.count {
            paramsString.append(String(describing: params[i]))
        }
        if orderby.count > 0 {
            let colsjoined = orderby.joined(separator: ",")
            clauseOrder = " ORDER BY \(colsjoined)"
        }
        do {
            let getCount = try execRows("SELECT \(clauseCount) FROM \(table()) \(clauseWhere)", params: paramsString)
            var numrecords = 0
            if (getCount.first != nil) {
                numrecords = getCount.first?.data["counter"] as? Int ?? 0
            }
            results.cursorData = StORMCursor(
                limit: cursor.limit,
                offset: cursor.offset,
                totalRecords: numrecords)
            
            if numrecords == 0 { return }
            // SELECT ASSEMBLE
            var str = "SELECT \(clauseSelectList.lowercased()) FROM \(table()) \(clauseWhere) \(clauseOrder)"
            
            
            // TODO: Add joins, having, groupby
            
            if cursor.limit > 0 {
                str += " LIMIT \(cursor.limit)"
            }
            if cursor.offset > 0 {
                str += " OFFSET \(cursor.offset)"
            }
            
            // save results into ResultSet
            results.rows = try execRows(str, params: paramsString)
            
            // if just one row returned, act like a "GET"
            if results.cursorData.totalRecords == 1 { makeRow() }
            
            //return results
        } catch {
            LogFile.error("Error msg: \(error)", logFile: "./StORMlog.txt")
            self.error = StORMError.error("\(error)")
            throw error
        }
    }
    public func sql_ex(_ statement: String, params: [String]) throws {
        results.rows = try execRows(statement, params: params)
        if results.cursorData.totalRecords == 1 { makeRow() }
    }
    @discardableResult
    fileprivate func execRows(_ statement: String, params: [String]) throws -> [StORMRow] {
        let thisConnection = PostgresConnect(
            host:        PostgresConnector.host,
            username:    PostgresConnector.username,
            password:    PostgresConnector.password,
            database:    PostgresConnector.database,
            port:        PostgresConnector.port
        )
        
        thisConnection.open()
        if thisConnection.state == .bad {
            error = .connectionError
            throw StORMError.error("Connection Error")
        }
        thisConnection.statement = statement
        
        let result = thisConnection.server.exec(statement: statement, params: params)
        
        // set exec message
        errorMsg = thisConnection.server.errorMessage().trimmingCharacters(in: .whitespacesAndNewlines)
        if StORMdebug { LogFile.info("Error msg: \(errorMsg)", logFile: "./StORMlog.txt") }
        if isError() {
            thisConnection.server.close()
            throw StORMError.error(errorMsg)
        }
        
        let resultRows = parseRows(result)
        //        result.clear()
        thisConnection.server.close()
        return resultRows
    }
    fileprivate func isError() -> Bool {
        if errorMsg.contains(string: "ERROR"), !PostgresConnector.quiet {
            print(errorMsg)
            return true
        }
        return false
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
