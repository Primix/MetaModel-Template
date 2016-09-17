//
//  Relation.swift
//  MetaModel
//
//  Created by Draveness on 8/23/16.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation

open class Relation<T> {
    fileprivate var complete: Bool = false
    var select: String = ""
    var filter: [String] = []
    var order: [String] = []
    var group: [String] = []
    var limit: String = ""
    var offset: String = ""

    var query: String {
        get {
            let selectClouse = select
            let whereClouse = filter.count == 0 ? "" : "WHERE \(filter.joined(separator: " AND "))"
            let groupClouse = group.count == 0 ? "" : "GROUP BY \(group.joined(separator: ", "))"
            let orderClouse = order.count == 0 ? "" : "ORDER BY \(order.joined(separator: ", "))"

            return [selectClouse, whereClouse, groupClouse, orderClouse, limit, offset].filter {
                $0.characters.count > 0
            }.joined(separator: " ")
        }
    }

    var result: [T] {
        get {
            return []
        }
    }

    open var all: Relation<T> {
        get {
            return self
        }
    }

    open var first: T? {
        get {
            return result.first
        }
    }

    open func offset(_ offset: UInt) -> Self {
        self.offset = "OFFSET \(offset)"
        return self
    }

    open func limit(_ length: UInt, offset: UInt = 0) -> Self {
        self.limit = "LIMIT \(length)"
        if offset != 0 {
            self.offset = "OFFSET \(offset)"
        }
        return self
    }
    
    open func take(_ length: UInt) -> Self {
        return self.limit(length)
    }
}

extension Relation: Sequence {
    public typealias Iterator = AnyIterator<T>

    public func makeIterator() -> Iterator {
        var index = 0
        return AnyIterator {
            if index < self.result.count {
                let element = self.result[index]
                index += 1
                return element
            }
            return nil
        }
    }
}

extension Relation: Collection {
    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Int) -> Int {
        if i < endIndex {
            return i + 1
        }
        return i
    }

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
        let desc: NSString = result.description as NSString
        let content: String = desc
            .substring(with: NSRange(location: 1, length: result.description.characters.count - 2))
            .components(separatedBy: "), ")
            .joined(separator: "), \n\t")
            .replacingOccurrences(of: "MetaModel.", with: "")

        return "[\n\t\(content)\n]"
    }
}
