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
    
    public func take(length: UInt) -> Self {
        return self.limit(length)
    }
}

extension Relation: SequenceType {
    public typealias Generator = AnyGenerator<T>

    public func generate() -> Generator {
        var index = 0
        return AnyGenerator {
            if index < self.result.count {
                let element = self.result[index]
                index += 1
                return element
            }
            return nil
        }
    }
}

extension Relation: CollectionType {
    public typealias Index = Int

    public var startIndex: Int {
        return 0
    }

    public var endIndex: Int {
        return self.result.count
    }

    public subscript(index: Int) -> T {
        return self.result[index]
    }
}

extension Relation: CustomStringConvertible {
    public var description: String {
        let desc: NSString = result.description
        let content: String = desc
            .substringWithRange(NSRange(location: 1, length: result.description.characters.count - 2))
            .componentsSeparatedByString("), ")
            .joinWithSeparator("), \n\t")

        return "[\n\t\(content)\n]".stringByReplacingOccurrencesOfString("MetaModel.", withString: "")
    }
}