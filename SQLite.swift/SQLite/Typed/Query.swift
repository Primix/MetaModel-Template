//
// SQLite.swift
// https://github.com/stephencelis/SQLite.swift
// Copyright © 2014-2015 Stephen Celis.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

public protocol QueryType : Expressible {

    var clauses: QueryClauses { get set }

    init(_ name: String, database: String?)

}

public protocol SchemaType : QueryType {

    static var identifier: String { get }

}

public struct Row {

    private let columnNames: [String: Int]

    private let values: [Binding?]

    private init(_ columnNames: [String: Int], _ values: [Binding?]) {
        self.columnNames = columnNames
        self.values = values
    }

    /// Returns a row’s value for the given column.
    ///
    /// - Parameter column: An expression representing a column selected in a Query.
    ///
    /// - Returns: The value for the given column.
    public func get<V: Value>(column: Expression<V>) -> V {
        return get(Expression<V?>(column))!
    }
    public func get<V: Value>(column: Expression<V?>) -> V? {
        func valueAtIndex(idx: Int) -> V? {
            guard let value = values[idx] as? V.Datatype else { return nil }
            return (V.fromDatatypeValue(value) as? V)!
        }

        guard let idx = columnNames[column.template] else {
            let similar = Array(columnNames.keys).filter { $0.hasSuffix(".\(column.template)") }

            switch similar.count {
            case 0:
                fatalError("no such column '\(column.template)' in columns: \(columnNames.keys.sort())")
            case 1:
                return valueAtIndex(columnNames[similar[0]]!)
            default:
                fatalError("ambiguous column '\(column.template)' (please disambiguate: \(similar))")
            }
        }

        return valueAtIndex(idx)
    }

    // FIXME: rdar://problem/18673897 // subscript<T>…

    public subscript(column: Expression<Blob>) -> Blob {
        return get(column)
    }
    public subscript(column: Expression<Blob?>) -> Blob? {
        return get(column)
    }

    public subscript(column: Expression<Bool>) -> Bool {
        return get(column)
    }
    public subscript(column: Expression<Bool?>) -> Bool? {
        return get(column)
    }

    public subscript(column: Expression<Double>) -> Double {
        return get(column)
    }
    public subscript(column: Expression<Double?>) -> Double? {
        return get(column)
    }

    public subscript(column: Expression<Int>) -> Int {
        return get(column)
    }
    public subscript(column: Expression<Int?>) -> Int? {
        return get(column)
    }

    public subscript(column: Expression<Int64>) -> Int64 {
        return get(column)
    }
    public subscript(column: Expression<Int64?>) -> Int64? {
        return get(column)
    }

    public subscript(column: Expression<String>) -> String {
        return get(column)
    }
    public subscript(column: Expression<String?>) -> String? {
        return get(column)
    }

}

/// Determines the join operator for a query’s `JOIN` clause.
public enum JoinType : String {

    /// A `CROSS` join.
    case Cross = "CROSS"

    /// An `INNER` join.
    case Inner = "INNER"

    /// A `LEFT OUTER` join.
    case LeftOuter = "LEFT OUTER"

}

/// ON CONFLICT resolutions.
public enum OnConflict: String {

    case Replace = "REPLACE"

    case Rollback = "ROLLBACK"

    case Abort = "ABORT"

    case Fail = "FAIL"

    case Ignore = "IGNORE"

}

// MARK: - Private

public struct QueryClauses {

    var select = (distinct: false, columns: [Expression<Void>(literal: "*") as Expressible])

    var from: (name: String, alias: String?, database: String?)

    var join = [(type: JoinType, query: QueryType, condition: Expressible)]()

    var filters: Expression<Bool?>?

    var group: (by: [Expressible], having: Expression<Bool?>?)?

    var order = [Expressible]()

    var limit: (length: Int, offset: Int?)?

    private init(_ name: String, alias: String?, database: String?) {
        self.from = (name, alias, database)
    }

}
