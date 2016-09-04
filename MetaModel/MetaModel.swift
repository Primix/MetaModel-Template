//
//  MetaModel.swift
//  MetaModel
//
//  Created by Draveness on 8/22/16.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation
import SQLite

let path = NSSearchPathForDirectoriesInDomains(
    .DocumentDirectory, .UserDomainMask, true
).first! as String

let db =  try! Connection("\(path)/db1.sqlite3")

public class MetaModel {
    public static func initialize() {
        Person.initialize()
    }
}

func executeSQL(sql: String, success: (() -> ())? = nil) -> Statement? {
    defer { print("\n") }
    print("-> Begin Transaction")
    let startDate = NSDate()
    do {
        let result = try db.run(sql)
        let endDate = NSDate()
        let interval = endDate.timeIntervalSinceDate(startDate) * 1000
        print("\tSQL (\(interval.format("0.2"))ms) \(sql)")
        print("-> Commit Transaction")

        if let success = success {
            success()
        }

        return result
    } catch let error {
        let endDate = NSDate()
        let interval = endDate.timeIntervalSinceDate(startDate) * 1000
        print("\tSQL (\(interval.format("0.2"))ms) \(sql)")
        print("\t\(error)")
        print("-> Rollback transaction")
    }
    return nil
}

//func executeQuery(sql: String) -> Statement? {
//    print("-> Begin Transaction")
//    defer { print("-> Commit Transaction") }
//    print("\tSQL \(sql)")
//    do {
//        return try db.prepare(sql)
//    } catch {
//
//    }
//    return nil
//}
