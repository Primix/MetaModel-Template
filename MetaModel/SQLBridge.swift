//
//  SQLBridge.swift
//  MetaModel
//
//  Created by Draveness on 9/11/16.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation

func executeSQL(sql: String, verbose: Bool = false, suppress: Bool = false, success: (() -> ())? = nil) -> Statement? {
    if verbose {
        print("-> Begin Transaction")
    }
    let startDate = NSDate()
    do {
        let result = try db.run(sql)
        let endDate = NSDate()
        let interval = endDate.timeIntervalSinceDate(startDate) * 1000

        if verbose {
            print("\tSQL (\(interval.format("0.2"))ms) \(sql)")
            print("-> Commit Transaction")
            print("\n")
        }
        if let success = success {
            success()
        }

        return result
    } catch let error {
        let endDate = NSDate()
        let interval = endDate.timeIntervalSinceDate(startDate) * 1000
        print("\tSQL (\(interval.format("0.2"))ms) \(sql)")
        print("\t\(error)")
        if verbose {
            print("-> Rollback transaction")
            print("\n")
        }
    }
    return nil
}

func executeScalarSQL(sql: String, verbose: Bool = false, suppress: Bool = false, success: (() -> ())? = nil) -> Binding? {
    if verbose {
        print("-> Begin Transaction")
    }
    let startDate = NSDate()
    let result = db.scalar(sql)
    let endDate = NSDate()
    let interval = endDate.timeIntervalSinceDate(startDate) * 1000
    if verbose {
        print("\tSQL (\(interval.format("0.2"))ms) \(sql)")
        print("-> Commit Transaction")
        print("\n")
    }

    if let success = success {
        success()
    }

    return result
}
