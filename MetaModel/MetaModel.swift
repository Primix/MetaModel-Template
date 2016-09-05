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

let db =  try! Connection("\(path)/db.sqlite3")

public class MetaModel {
    public static func initialize() {
        validateMetaModelTables()

        Person.initialize()
    }

    static func validateMetaModelTables() {
        createMetaModelTable()
        let infos = retrieveMetaModelTableInfos()
        if infos[Person.tableName] != "daadaadada" {
            updateMetaModelTableInfos(Person.tableName, hashValue: "daadaadada")
            Person.deinitialize()
        }
    }
}

func executeSQL(sql: String, silent: Bool = false, success: (() -> ())? = nil) -> Statement? {
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

