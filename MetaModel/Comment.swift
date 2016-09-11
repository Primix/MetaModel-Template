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
        let initializeTableSQL = "CREATE TABLE comments(_id INTEGER PRIMARY KEY, id INTEGER UNIQUE DEFAULT 0, content TEXT, articleId INTEGER DEFAULT 0, FOREIGN KEY(articleId) REFERENCES ints(_id));"
        executeSQL(initializeTableSQL)
    }
    static func deinitialize() {
        let dropTableSQL = "DROP TABLE \(tableName.unwrapped)"
        executeSQL(dropTableSQL)
    }
}

public struct Comment {
    public var id: Int
    public var content: String
    public var articleId: Int
    
    static let tableName = "comments"

    public enum Column: String, Unwrapped {
        case id = "id"
        case content = "content"
        case articleId = "articleId"
        
        var unwrapped: String { get { return self.rawValue.unwrapped } }
    }

    public init(id: Int = 0, content: String, articleId: Int = 0) {
        self.id = id
        self.content = content
        self.articleId = articleId
        
    }

    static public func new(id id: Int = 0, content: String, articleId: Int = 0) -> Comment {
        return Comment(id: id, content: content, articleId: articleId)
    }

    static public func create(id id: Int = 0, content: String, articleId: Int = 0) -> Comment? {
        if id == 0 || articleId == 0 { return nil }

        var columnsSQL: [Comment.Column] = []
        var valuesSQL: [Unwrapped] = []

        columnsSQL.append(.id)
        valuesSQL.append(id)
        
        columnsSQL.append(.content)
        valuesSQL.append(content)
        
        columnsSQL.append(.articleId)
        valuesSQL.append(articleId)
        
        let insertSQL = "INSERT INTO \(tableName.unwrapped) (\(columnsSQL.map { $0.rawValue }.joinWithSeparator(", "))) VALUES (\(valuesSQL.map { $0.unwrapped }.joinWithSeparator(", ")))"
        guard let _ = executeSQL(insertSQL) else { return nil }
        return Comment(id: id, content: content, articleId: articleId)
    }
}

// MARK: - Update

public extension Comment {
    mutating func update(content content: String = StringDefaultValue, articleId: Int = IntDefaultValue) -> Comment {
        var attributes: [Comment.Column: Any] = [:]
        if (content != StringDefaultValue) { attributes[.content] = content }
        if (articleId != IntDefaultValue) { attributes[.articleId] = articleId }
        return self.update(attributes)
    }

    mutating func update(attributes: [Comment.Column: Any]) -> Comment {
        var setSQL: [String] = []
        if let attributes = attributes as? [Comment.Column: Unwrapped] {
            for (key, value) in attributes {
                switch key {
                case .content: setSQL.append("\(key.unwrapped) = \(value.unwrapped)")
                case .articleId: setSQL.append("\(key.unwrapped) = \(value.unwrapped)")
                default: break
                }
            }
            let updateSQL = "UPDATE \(Comment.tableName.unwrapped) SET \(setSQL.joinWithSeparator(", ")) \(itself)"
            executeSQL(updateSQL) {
                for (key, value) in attributes {
                    switch key {
                    case .content: self.content = value as! String
                    case .articleId: self.articleId = value as! Int
                    default: break
                    }
                }
            }
        }
        return self
    }

    var save: Comment {
        mutating get {
            if let _ = Comment.find(id) {
                update([.id: id, .content: content, .articleId: articleId])
            } else {
                Comment.create(id: id, content: content, articleId: articleId)
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
    public func updateAll(column: Comment.Column, value: Any) {
        self.result.forEach { (element) in
            var element = element
            element.update([column: value])
        }
    }
}

// MARK: - Query

public extension Comment {
    static var all: CommentRelation {
        get { return CommentRelation() }
    }

    static var first: Comment? {
        get {
            return CommentRelation().orderBy(.id, asc: true).first
        }
    }

    static var last: Comment? {
        get {
            return CommentRelation().orderBy(.id, asc: false).first
        }
    }

    static func first(length: UInt) -> CommentRelation {
        return CommentRelation().orderBy(.id, asc: true).limit(length)
    }

    static func last(length: UInt) -> CommentRelation {
        return CommentRelation().orderBy(.id, asc: false).limit(length)
    }

    static func find(id: Int) -> Comment? {
        return CommentRelation().find(id).first
    }

    static func findBy(id id: Int = IntDefaultValue, content: String = StringDefaultValue, articleId: Int = IntDefaultValue) -> CommentRelation {
        var attributes: [Comment.Column: Any] = [:]
        if (id != IntDefaultValue) { attributes[.id] = id }
        if (content != StringDefaultValue) { attributes[.content] = content }
        if (articleId != IntDefaultValue) { attributes[.articleId] = articleId }
        return CommentRelation().filter(attributes)
    }

    static func filter(id id: Int = IntDefaultValue, content: String = StringDefaultValue, articleId: Int = IntDefaultValue) -> CommentRelation {
        return findBy(id: id, content: content, articleId: articleId)
    }

    static func limit(length: UInt, offset: UInt = 0) -> CommentRelation {
        return CommentRelation().limit(length, offset: offset)
    }

    static func take(length: UInt) -> CommentRelation {
        return limit(length)
    }

    static func offset(offset: UInt) -> CommentRelation {
        return CommentRelation().offset(offset)
    }

    static func groupBy(columns: Comment.Column...) -> CommentRelation {
        return CommentRelation().groupBy(columns)
    }

    static func groupBy(columns: [Comment.Column]) -> CommentRelation {
        return CommentRelation().groupBy(columns)
    }

    static func orderBy(column: Comment.Column) -> CommentRelation {
        return CommentRelation().orderBy(column)
    }

    static func orderBy(column: Comment.Column, asc: Bool) -> CommentRelation {
        return CommentRelation().orderBy(column, asc: asc)
    }
}

public extension CommentRelation {
    func find(id: Int) -> Self {
        return findBy(id: id)
    }

    func findBy(id id: Int = IntDefaultValue, content: String = StringDefaultValue, articleId: Int = IntDefaultValue) -> Self {
        var attributes: [Comment.Column: Any] = [:]
        if (id != IntDefaultValue) { attributes[.id] = id }
        if (content != StringDefaultValue) { attributes[.content] = content }
        if (articleId != IntDefaultValue) { attributes[.articleId] = articleId }
        return self.filter(attributes)
    }

    func filter(id id: Int = IntDefaultValue, content: String = StringDefaultValue, articleId: Int = IntDefaultValue) -> Self {
        return findBy(id: id, content: content, articleId: articleId)
    }

    func filter(conditions: [Comment.Column: Any]) -> Self {
        for (column, value) in conditions {
            let columnSQL = "\(expandColumn(column))"

            func filterByEqual(value: Any) {
                self.filter.append("\(columnSQL) = \(value)")
            }

            func filterByIn(value: [String]) {
                self.filter.append("\(columnSQL) IN (\(value.joinWithSeparator(", ")))")
            }

            if let value = value as? String {
                filterByEqual(value.unwrapped)
            } else if let value = value as? Int {
                filterByEqual(value)
            } else if let value = value as? Double {
                filterByEqual(value)
            } else if let value = value as? [String] {
                filterByIn(value.map { $0.unwrapped })
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
        return self.groupBy(columns)
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
        self.order.append("\(expandColumn(column)) \(asc ? "ASC".unwrapped : "DESC".unwrapped)")
        return self
    }
}

// MARK: - Delete

public extension Comment {
    var delete: Bool {
        get {
            let deleteSQL = "DELETE FROM \(Comment.tableName.unwrapped) \(itself)"
            executeSQL(deleteSQL)
            return true
        }
    }
    static func deleteAll() {
        let deleteAllSQL = "DELETE FROM \(tableName.unwrapped)"
        executeSQL(deleteAllSQL)
    }
}

public extension CommentRelation {
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
            let countSQL = "SELECT count(*) FROM \(tableName.unwrapped)"
            guard let count = executeScalarSQL(countSQL) as? Int64 else { return 0 }
            return Int(count)
        }
    }
}

// MARK: - Association

public extension Comment {
    var article: Article? {
        get {
            return Article.find(id)
        }
        set {
            guard let newValue = newValue else { return }
            update(articleId: newValue.id)
        }
    }

}

// MAKR: - Helper

public class CommentRelation: Relation<Comment> {
    override init() {
        super.init()
        self.select = "SELECT \(Comment.tableName.unwrapped).* FROM \(Comment.tableName.unwrapped)"
    }

    override var result: [Comment] {
        get {
            var models: [Comment] = []
            guard let stmt = executeSQL(query) else { return models }
            for values in stmt {
                models.append(Comment(values: values))
            }
            return models
        }
    }

    func expandColumn(column: Comment.Column) -> String {
        return "\(Comment.tableName.unwrapped).\(column.unwrapped)"
    }
}

extension Comment {
    init(values: Array<Optional<Binding>>) {
        let id: Int64 = values[1] as! Int64
        let content: String = values[2] as! String
        let articleId: Int64 = values[3] as! Int64
        
        self.init(id: Int(id), content: String(content), articleId: Int(articleId))
    }
}

extension Comment {
    var itself: String { get { return "WHERE \(Article.tableName.unwrapped).\("id".unwrapped) = \(id)" } }
}
