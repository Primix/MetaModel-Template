//
//  MetaModel.swift
//  MetaModel
//
//  Created by Draveness on 8/22/16.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation

let path = NSSearchPathForDirectoriesInDomains(
    .DocumentDirectory, .UserDomainMask, true
).first! as String

let db =  try! Connection("\(path)/db1.sqlite3")

public class MetaModel {
    public static func initialize() {
        validateMetaModelTables()
    }

    static func validateMetaModelTables() {
        createMetaModelTable()
        let infos = retrieveMetaModelTableInfos()
        if infos[Person.tableName] != "daadaadssada" {
            updateMetaModelTableInfos(Person.tableName, hashValue: "daadaadssada")
            Person.deinitialize()
            Person.initialize()
        }
    }
}

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
        if !suppress {
            print("\tSQL (\(interval.format("0.2"))ms) \(sql)")
            print("\t\(error)")
        }
        if verbose {
            print("-> Rollback transaction")
            print("\n")
        }
    }
    return nil
}

func executeScalarSQL(sql: String, verbose: Bool = false, supress: Bool = false, success: (() -> ())? = nil) -> Binding? {
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