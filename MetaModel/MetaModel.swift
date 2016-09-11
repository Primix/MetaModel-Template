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
        if infos[Article.tableName] != "179e895bda1bdfc9" {
            updateMetaModelTableInfos(Article.tableName, hashValue: "179e895bda1bdfc9")
            Article.deinitialize()
            Article.initialize()
        }
        if infos[Comment.tableName] != "-3f9a0d7eb5238992" {
            updateMetaModelTableInfos(Comment.tableName, hashValue: "-3f9a0d7eb5238992")
            Comment.deinitialize()
            Comment.initialize()
        }
    }
}
