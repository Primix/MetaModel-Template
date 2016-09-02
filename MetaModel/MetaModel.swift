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
        Person.createTable()
    }
}

func executeSQL(sql: String) -> Statement? {
    print("-> MetaModel SQL: \(sql)")
    do {
        return try db.run(sql)
    } catch {

    }
    return nil
}

func executeQuery(sql: String) -> Statement? {
    print("-> Begin Transaction")
    defer { print("-> Commit Transaction") }
    print("\tSQL \(sql)")
    do {
        return try db.prepare(sql)
    } catch {

    }
    return nil
}

extension String {
    var quotes: String {
        get {
            return "\"\(self)\""
        }
    }
}