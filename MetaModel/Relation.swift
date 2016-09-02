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
    init(values: Array<Optional<Binding>>)
}

public class Relation<T: Recordable> {
    private var complete: Bool = false
    var query: String {
        get {
            let selectClouse = select
            let whereClouse = filter.count == 0 ? "" : "WHERE \(filter.joinWithSeparator(" AND "))"
            let result = "\(selectClouse) \(whereClouse) \(limit) \(offset)"
            return result
        }
    }

    var select: String = "" {
        didSet {
            complete = false
        }
    }

    var filter: [String] = [] {
        didSet {
            complete = false
        }
    }

    var group: [String] = [] {
        didSet {
            complete = false
        }
    }

    var limit: String = "" {
        didSet {
            complete = false
        }
    }

    var offset: String = "" {
        didSet {
            complete = false
        }
    }

    var result: [T] {
        get {
            var models: [T] = []
            if !complete {
                complete = true
                for values in try! db.prepare(query) {
                    models.append(T(values: values))
                }
            }
            return models
        }
    }

//    init(query: String) {
//        self.query = query
//    }

    public subscript(index: Int) -> T {
        get {
            return result[index]
        }
    }

    public var all: Relation<T> {
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