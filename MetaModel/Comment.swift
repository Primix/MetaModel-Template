//
//  Comment.swift
//  MetaModel
//
//  Created by MetaModel.
//  Copyright © 2016 MetaModel. All rights reserved.
//

import Foundation

extension Comment {
    static func initialize() {
        let initializeTableSQL = "CREATE TABLE comments(private_id INTEGER PRIMARY KEY, content TEXT);"
        executeSQL(initializeTableSQL)
    }
    static func deinitialize() {
        let dropTableSQL = "DROP TABLE \(tableName)"
        executeSQL(dropTableSQL)
    }
}

public struct Comment {
    var privateId: Int = 0
    public var content: String
    
    static let tableName = "comments"

    public enum Column: String, CustomStringConvertible {
        case content = "content"
        
        case privateId = "private_id"

        public var description: String { get { return self.rawValue } }
    }

    public init(content: String) {
        self.content = content
        
    }

    @discardableResult static public func new(content: String) -> Comment {
        return Comment(content: content)
    }

    @discardableResult static public func create(content: String) -> Comment? {
        //if false == true { return nil }

        var columnsSQL: [Comment.Column] = []
        var valuesSQL: [Unwrapped] = []

        
        columnsSQL.append(.content)
        valuesSQL.append(content)
        
        let insertSQL = "INSERT INTO \(tableName) (\(columnsSQL.map { $0.rawValue }.joined(separator: ", "))) VALUES (\(valuesSQL.map { $0.unwrapped }.joined(separator: ", ")))"
        guard let _ = executeSQL(insertSQL),
          let lastInsertRowId = executeScalarSQL("SELECT last_insert_rowid();") as? Int64 else { return nil }
        var result = Comment(content: content)
        result.privateId = Int(lastInsertRowId)
        return result
    }
}

// MARK: - Update

public extension Comment {
    @discardableResult mutating func update(content: String = StringDefaultValue) {
        var attributes: [Comment.Column: Any] = [:]
        if (content != StringDefaultValue) { attributes[.content] = content }
        
        self.update(attributes: attributes)
    }

    @discardableResult mutating func update(attributes: [Comment.Column: Any]) {
        var setSQL: [String] = []
        if let attributes = attributes as? [Comment.Column: Unwrapped] {
            for (key, value) in attributes {
                switch key {
                case .content: setSQL.append("\(key) = \(value.unwrapped)")
                default: break
                }
            }
            let updateSQL = "UPDATE \(Comment.tableName) SET \(setSQL.joined(separator: ", ")) \(itself)"
            guard let _ = executeSQL(updateSQL) else { return }
            for (key, value) in attributes {
                switch key {
                case .content: self.content = value as! String
                default: break
                }
            }
        }
    }

    var save: Comment {
        mutating get {
            if let _ = Comment.find(privateId) {
                update(attributes: [.content: content])
            } else {
                Comment.create(content: content)
            }
            return self
        }
    }

    var commit: Comment {
        mutating get {
            return save
        }
    }
}

public extension CommentRelation {
    @discardableResult public func updateAll(content: String = StringDefaultValue) -> Self {
        return update(content: content)
    }

    @discardableResult public func update(content: String = StringDefaultValue) -> Self {
        var attributes: [Comment.Column: Any] = [:]
        if (content != StringDefaultValue) { attributes[.content] = content }
        
        result.forEach { (element) in
            var element = element
            element.update(attributes: attributes)
        }
        return self
    }
}

// MARK: - Query

public extension Comment {
    static var all: CommentRelation {
        get { return CommentRelation() }
    }

    static var first: Comment? {
        get {
            return CommentRelation().orderBy(column: .privateId, asc: true).first
        }
    }

    static var last: Comment? {
        get {
            return CommentRelation().orderBy(column: .privateId, asc: false).first
        }
    }

    static func first(length: UInt) -> CommentRelation {
        return CommentRelation().orderBy(column: .privateId, asc: true).limit(length)
    }

    static func last(length: UInt) -> CommentRelation {
        return CommentRelation().orderBy(column: .privateId, asc: false).limit(length)
    }

    internal static func find(_ privateId: Int) -> Comment? {
        return CommentRelation().find(privateId).first
    }

    internal static func find(_ privateIds: [Int]) -> CommentRelation {
        return CommentRelation().find(privateIds)
    }

    static func findBy(content: String = StringDefaultValue) -> CommentRelation {
        return CommentRelation().findBy(content: content)
    }

    static func filter(content: String = StringDefaultValue) -> CommentRelation {
        return CommentRelation().filter(content: content)
    }

    static func limit(length: UInt, offset: UInt = 0) -> CommentRelation {
        return CommentRelation().limit(length, offset: offset)
    }

    static func take(length: UInt) -> CommentRelation {
        return CommentRelation().limit(length)
    }

    static func offset(offset: UInt) -> CommentRelation {
        return CommentRelation().offset(offset)
    }

    static func groupBy(columns: Comment.Column...) -> CommentRelation {
        return CommentRelation().groupBy(columns: columns)
    }

    static func groupBy(columns: [Comment.Column]) -> CommentRelation {
        return CommentRelation().groupBy(columns: columns)
    }

    static func orderBy(column: Comment.Column) -> CommentRelation {
        return CommentRelation().orderBy(column: column)
    }

    static func orderBy(column: Comment.Column, asc: Bool) -> CommentRelation {
        return CommentRelation().orderBy(column: column, asc: asc)
    }
}

public extension CommentRelation {
    func findBy(content: String = StringDefaultValue) -> Self {
        var attributes: [Comment.Column: Any] = [:]
        if (content != StringDefaultValue) { attributes[.content] = content }
        return self.filter(conditions: attributes)
    }

    func filter(content: String = StringDefaultValue) -> Self {
        return findBy(content: content)
    }

    func filter(conditions: [Comment.Column: Any]) -> Self {
        for (column, value) in conditions {
            let columnSQL = "\(expandColumn(column))"

            func filterByEqual(_ value: Any) {
                self.filter.append("\(columnSQL) = \(value)")
            }

            func filterByIn(_ value: [String]) {
                self.filter.append("\(columnSQL) IN (\(value.joined(separator: ", ")))")
            }

            if let value = value as? String {
                filterByEqual(value)
            } else if let value = value as? Int {
                filterByEqual(value)
            } else if let value = value as? Double {
                filterByEqual(value)
            } else if let value = value as? [String] {
                filterByIn(value.map { $0 })
            } else if let value = value as? [Int] {
                filterByIn(value.map { $0.description })
            } else if let value = value as? [Double] {
                filterByIn(value.map { $0.description })
            } else {
                let valueMirror = Mirror(reflecting: value)
                print("!!!: UNSUPPORTED TYPE \(valueMirror.subjectType)")
            }

        }
        return self
    }

    func groupBy(columns: Comment.Column...) -> Self {
        return self.groupBy(columns: columns)
    }

    func groupBy(columns: [Comment.Column]) -> Self {
        func groupBy(column: Comment.Column) {
            self.group.append("\(expandColumn(column))")
        }
        _ = columns.flatMap(groupBy)
        return self
    }

    func orderBy(column: Comment.Column) -> Self {
        self.order.append("\(expandColumn(column))")
        return self
    }

    func orderBy(column: Comment.Column, asc: Bool) -> Self {
        self.order.append("\(expandColumn(column)) \(asc ? "ASC" : "DESC")")
        return self
    }
}

// MARK: - Delete

public extension Comment {
    var delete: Bool {
        get {
            let deleteSQL = "DELETE FROM \(Comment.tableName) \(itself)"
            executeSQL(deleteSQL)
            return true
        }
    }
    static var deleteAll: Bool { get { return CommentRelation().deleteAll } }
}

public extension CommentRelation {
    var delete: Bool { get { return deleteAll } }

    var deleteAll: Bool {
        get {
            self.result.forEach { $0.delete }
            return true
        }
    }
}

public extension Comment {
    static var count: Int {
        get {
            let countSQL = "SELECT count(*) FROM \(tableName)"
            guard let count = executeScalarSQL(countSQL) as? Int64 else { return 0 }
            return Int(count)
        }
    }
}

// MAKR: - Helper

open class CommentRelation: Relation<Comment> {
    override init() {
        super.init()
        self.select = "SELECT \(Comment.tableName).* FROM \(Comment.tableName)"
    }

    override var result: [Comment] {
        get {
            return MetaModels.fromQuery(query)
        }
    }

    func expandColumn(_ column: Comment.Column) -> String {
        return "\(Comment.tableName).\(column)"
    }
}

extension Comment {
    var itself: String { get { return "WHERE \(Comment.tableName).private_id = \(privateId)" } }
}

extension CommentRelation {
    func find(_ privateId: Int) -> Self {
        return filter(privateId)
    }

    func find(_ privateIds: [Int]) -> Self {
        return filter(conditions: [.privateId: privateIds])
    }

    func filter(_ privateId: Int) -> Self {
        self.filter.append("private_id = \(privateId)")
        return self
    }
}
