//
//  MetaModel.swift
//  MetaModel
//
//  Created by 左书祺 on 8/22/16.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation
import SQLite

let db = try! Connection("path/to/db.sqlite3")

class MetaModel {
    static func initialize() -> Bool {
        Person.meta.createTable()
        return true
    }
}


let entry = MetaModel.initialize()