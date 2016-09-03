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
    var select: String = ""
    var filter: [String] = []
    var order: [String] = []
    var group: [String] = []
    var limit: String = ""
    var offset: String = ""

    var query: String {
        get {
            let selectClouse = select
            let whereClouse = filter.count == 0 ? "" : "WHERE \(filter.joinWithSeparator(" AND "))"
            let groupClouse = group.count == 0 ? "" : "GROUP BY \(group.joinWithSeparator(", "))"
            let orderClouse = order.count == 0 ? "" : "ORDER BY \(order.joinWithSeparator(", "))"
            let result = "\(selectClouse) \(whereClouse) \(groupClouse) \(limit) \(offset)"
            return result
        }
    }

    var result: [T] {
        get {
            var models: [T] = []
            guard let stmt = executeQuery(query) else { return models }
            for values in stmt {
                models.append(T(values: values))
            }
            return models
        }
    }

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

    public var first: T? {
        get {
            return result.first
        }
    }

}

extension Relation: CustomStringConvertible {
    public var description: String {
        return result.description
    }
}