//
//  Relation.swift
//  MetaModel
//
//  Created by Draveness on 8/23/16.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation
import SQLite

public protocol Recordable {
    init(record: SQLite.Row)
}

public class Relation<T: Recordable> {
    var complete: Bool = false
    var query: QueryType {
        didSet {
            complete = false
        }
    }
    var result: [T] {
        get {
            var models: [T] = []
            if !complete {
                complete = true
                for record in try! db.prepare(query) {
                    models.append(T(record: record))
                }
            }
            return models
        }
    }

    init(query: QueryType) {
        self.query = query
    }

    public subscript(index: Int) -> T {
        get {
            return result[index]
        }
    }

    var all: Relation<T> {
        get {
            return self
        }
    }

    public var first: T {
        get {
            return result[0]
        }
    }

}

extension Relation: CustomStringConvertible {
    public var description: String {
        return result.description
    }
}