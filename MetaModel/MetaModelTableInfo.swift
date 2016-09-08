//
//  MetaModelTableInfo.swift
//  MetaModel
//
//  Created by Draveness on 9/5/16.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation

typealias TableName = String
typealias HashValue = String

func createMetaModelTable() {
    let createSQL = "CREATE TABLE meta_model_tables(name TEXT PRIMARY KEY, hash TEXT NON NULL);"
    executeSQL(createSQL)
}

func retrieveMetaModelTableInfos() -> [TableName: HashValue] {
    let select = "SELECT * FROM meta_model_tables;"
    var models: [TableName: HashValue] = [:]
    guard let stmt = executeSQL(select) else { return [:] }
    for values in stmt {
        let name: TableName = values[0] as! TableName
        let hash: HashValue = values[1] as! HashValue
        models[name] = hash
    }
    return models
}

func updateMetaModelTableInfos(tableName: String, hashValue: String) {
    let insertSQL = "INSERT INTO meta_model_tables (name, hash) VALUES (\(tableName.unwrapped), \(hashValue.unwrapped));"
    executeSQL(insertSQL)

    let updateSQL = "UPDATE meta_model_tables SET hash = \(hashValue.unwrapped) WHERE name = \(tableName.unwrapped)"
    executeSQL(updateSQL)
}
