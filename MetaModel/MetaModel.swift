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
        Person.createTable()
    }
}

func executeSQL(sql: String) -> Statement? {
    print("MetaModel: \(sql)")
    do {
        return try db.run(sql)
    } catch {

    }
    return nil
}

func executeQuery(sql: String) -> Statement? {
    print("MetaModel: \(sql)")
    do {
        return try db.prepare(sql)
    } catch {

    }
    return nil
}