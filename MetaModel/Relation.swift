//
//  Relation.swift
//  MetaModel
//
//  Created by Draveness on 8/23/16.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation

public class Relation<T> {
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

            return [selectClouse, whereClouse, groupClouse, orderClouse, limit, offset].filter {
                $0.characters.count > 0
            }.joinWithSeparator(" ")
        }
    }

    var result: [T] {
        get {
            return []
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

    public func offset(offset: UInt) -> Self {
        self.offset = "OFFSET \(offset)"
        return self
    }

    public func limit(length: UInt, offset: UInt = 0) -> Self {
        self.limit = "LIMIT \(length)"
        if offset != 0 {
            self.offset = "OFFSET \(offset)"
        }
        return self
    }
}

extension Relation: CustomStringConvertible {
    public var description: String {
        return result.description
    }
}