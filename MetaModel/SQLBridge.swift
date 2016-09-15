//
//  SQLBridge.swift
//  MetaModel
//
//  Created by Draveness on 9/11/16.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation

func executeSQL(sql: String, verbose: Bool = false, suppress: Bool = false, success: (() -> ())? = nil) -> Statement? {
    let startDate = NSDate()
    do {
        let result = try db.run(sql)
        let endDate = NSDate()
        let interval = endDate.timeIntervalSinceDate(startDate) * 1000

        if verbose { print("SQL: SUCCEED  | (\(interval.format("0.2"))ms) \(sql)") }

        if let success = success { success() }

        return result
    } catch let error {
        let endDate = NSDate()
        let interval = endDate.timeIntervalSinceDate(startDate) * 1000
        if !suppress { print("SQL: ROLLBACK | (\(interval.format("0.2"))ms) \(sql) | ERROR: \(error)") }
    }
    return nil
}

func executeTransaction(sqls: [String], verbose: Bool = false, block: Void -> Void) -> [Statement] {
    var result: [Statement] = []
    let startDate = NSDate()
    do {
        try db.transaction {
            for sql in sqls {
                result.append(try db.run(sql))
            }
        }
    } catch let error {
        let endDate = NSDate()
        let interval = endDate.timeIntervalSinceDate(startDate) * 1000
        print("SQL: ROLLBACK | (\(interval.format("0.2"))ms) \(sqls) | ERROR: \(error)")
    }
    return result
}

func executeScalarSQL(sql: String, verbose: Bool = false, success: (() -> ())? = nil) -> Binding? {
    let startDate = NSDate()
    let result = db.scalar(sql)
    let endDate = NSDate()
    let interval = endDate.timeIntervalSinceDate(startDate) * 1000
    if verbose { print("SQL: SUCCEED  | (\(interval.format("0.2"))ms) \(sql)") }
    if let success = success { success() }
    return result
}
