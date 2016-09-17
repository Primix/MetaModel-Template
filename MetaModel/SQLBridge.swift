//
//  SQLBridge.swift
//  MetaModel
//
//  Created by Draveness on 9/11/16.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation

let path = NSSearchPathForDirectoriesInDomains(
    .documentDirectory, .userDomainMask, true
    ).first! as String

let db =  try! Connection("\(path)/metamodel_db.sqlite3")

@discardableResult func executeSQL(_ sql: String, verbose: Bool = false, suppress: Bool = false, success: (() -> ())? = nil) -> Statement? {
    let startDate = Date()
    do {
        let result = try db.run(sql)
        let endDate = Date()
        let interval = endDate.timeIntervalSince(startDate) * 1000

        if verbose { print("SQL: SUCCEED  | (\(interval.format("0.2"))ms) \(sql)") }

        if let success = success { success() }

        return result
    } catch let error {
        let endDate = Date()
        let interval = endDate.timeIntervalSince(startDate) * 1000
        if !suppress { print("SQL: ROLLBACK | (\(interval.format("0.2"))ms) \(sql) | ERROR: \(error)") }
    }
    return nil
}

@discardableResult func executeScalarSQL(_ sql: String, verbose: Bool = false, suppress: Bool = false, success: (() -> ())? = nil) -> Binding? {
    let startDate = Date()
    do {
        let result = try db.scalar(sql)
        let endDate = Date()
        let interval = endDate.timeIntervalSince(startDate) * 1000

        if verbose { print("SQL: SUCCEED  | (\(interval.format("0.2"))ms) \(sql)") }

        if let success = success { success() }

        return result
    } catch let error {
        let endDate = Date()
        let interval = endDate.timeIntervalSince(startDate) * 1000
        if !suppress { print("SQL: ROLLBACK | (\(interval.format("0.2"))ms) \(sql) | ERROR: \(error)") }
    }
    return nil
}

func executeTransaction(_ sqls: [String], verbose: Bool = false, block: (Void) -> Void) -> [Statement] {
    var result: [Statement] = []
    let startDate = Date()
    do {
        try db.transaction {
            for sql in sqls {
                result.append(try db.run(sql))
            }
        }
    } catch let error {
        let endDate = Date()
        let interval = endDate.timeIntervalSince(startDate) * 1000
        print("SQL: ROLLBACK | (\(interval.format("0.2"))ms) \(sqls) | ERROR: \(error)")
    }
    return result
}
