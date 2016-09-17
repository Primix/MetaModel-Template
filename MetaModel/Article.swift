//
//  Article.swift
//  MetaModel
//
//  Created by MetaModel.
//  Copyright © 2016 MetaModel. All rights reserved.
//

import Foundation

extension Article {
    static func initialize() {
        let initializeTableSQL = "CREATE TABLE articles(private_id INTEGER PRIMARY KEY, title TEXT, content TEXT, created_at REAL);"
        executeSQL(initializeTableSQL)
    }
    static func deinitialize() {
        let dropTableSQL = "DROP TABLE \(tableName)"
        executeSQL(dropTableSQL)
    }
}

public struct Article {
    var privateId: Int = 0
    public var title: String
    public var content: String
    public var createdAt: Date
    
    static let tableName = "articles"

    public enum Column: String, CustomStringConvertible {
        case title = "title"
        case content = "content"
        case createdAt = "created_at"
        
        case privateId = "private_id"

        public var description: String { get { return self.rawValue } }
    }

    public init(title: String, content: String, createdAt: Date) {
        self.title = title
        self.content = content
        self.createdAt = createdAt
        
    }

    @discardableResult static public func new(title: String, content: String, createdAt: Date) -> Article {
        return Article(title: title, content: content, createdAt: createdAt)
    }

    @discardableResult static public func create(title: String, content: String, createdAt: Date) -> Article? {
        //if false == true { return nil }

        var columnsSQL: [Article.Column] = []
        var valuesSQL: [Unwrapped] = []

        
        columnsSQL.append(.title)
        valuesSQL.append(title)
        
        columnsSQL.append(.content)
        valuesSQL.append(content)
        
        columnsSQL.append(.createdAt)
        valuesSQL.append(createdAt)
        
        let insertSQL = "INSERT INTO \(tableName) (\(columnsSQL.map { $0.rawValue }.joined(separator: ", "))) VALUES (\(valuesSQL.map { $0.unwrapped }.joined(separator: ", ")))"
        guard let _ = executeSQL(insertSQL),
          let lastInsertRowId = executeScalarSQL("SELECT last_insert_rowid();") as? Int64 else { return nil }
        var result = Article(title: title, content: content, createdAt: createdAt)
        result.privateId = Int(lastInsertRowId)
        return result
    }
}

// MARK: - Update

public extension Article {
    @discardableResult mutating func update(title: String = StringDefaultValue, content: String = StringDefaultValue, createdAt: Date = DateDefaultValue) {
        var attributes: [Article.Column: Any] = [:]
        if (title != StringDefaultValue) { attributes[.title] = title }
        if (content != StringDefaultValue) { attributes[.content] = content }
        if (createdAt != DateDefaultValue) { attributes[.createdAt] = createdAt }
        
        self.update(attributes: attributes)
    }

    @discardableResult mutating func update(attributes: [Article.Column: Any]) {
        var setSQL: [String] = []
        if let attributes = attributes as? [Article.Column: Unwrapped] {
            for (key, value) in attributes {
                switch key {
                case .title: setSQL.append("\(key) = \(value.unwrapped)")
                case .content: setSQL.append("\(key) = \(value.unwrapped)")
                case .createdAt: setSQL.append("\(key) = \(value.unwrapped)")
                default: break
                }
            }
            let updateSQL = "UPDATE \(Article.tableName) SET \(setSQL.joined(separator: ", ")) \(itself)"
            guard let _ = executeSQL(updateSQL) else { return }
            for (key, value) in attributes {
                switch key {
                case .title: title = value as! String
                case .content: content = value as! String
                case .createdAt: createdAt = value as! Date
                default: break
                }
            }
        }
    }

    var save: Article {
        mutating get {
            if let _ = Article.find(privateId) {
                update(attributes: [.title: title, .content: content, .createdAt: createdAt])
            } else {
                Article.create(title: title, content: content, createdAt: createdAt)
            }
            return self
        }
    }

    var commit: Article {
        mutating get {
            return save
        }
    }
}

public extension ArticleRelation {
    @discardableResult public func updateAll(title: String = StringDefaultValue, content: String = StringDefaultValue, createdAt: Date = DateDefaultValue) -> Self {
        return update(title: title, content: content, createdAt: createdAt)
    }

    @discardableResult public func update(title: String = StringDefaultValue, content: String = StringDefaultValue, createdAt: Date = DateDefaultValue) -> Self {
        var attributes: [Article.Column: Any] = [:]
        if (title != StringDefaultValue) { attributes[.title] = title }
        if (content != StringDefaultValue) { attributes[.content] = content }
        if (createdAt != DateDefaultValue) { attributes[.createdAt] = createdAt }
        
        result.forEach { (element) in
            var element = element
            element.update(attributes: attributes)
        }
        return self
    }
}

// MARK: - Query

public extension Article {
    static var all: ArticleRelation {
        get { return ArticleRelation() }
    }

    static var first: Article? {
        get {
            return ArticleRelation().orderBy(column: .privateId, asc: true).first
        }
    }

    static var last: Article? {
        get {
            return ArticleRelation().orderBy(column: .privateId, asc: false).first
        }
    }

    static func first(length: UInt) -> ArticleRelation {
        return ArticleRelation().orderBy(column: .privateId, asc: true).limit(length)
    }

    static func last(length: UInt) -> ArticleRelation {
        return ArticleRelation().orderBy(column: .privateId, asc: false).limit(length)
    }

    internal static func find(_ privateId: Int) -> Article? {
        return ArticleRelation().find(privateId).first
    }

    internal static func find(_ privateIds: [Int]) -> ArticleRelation {
        return ArticleRelation().find(privateIds)
    }

    static func findBy(title: String = StringDefaultValue, content: String = StringDefaultValue, createdAt: Date = DateDefaultValue) -> ArticleRelation {
        return ArticleRelation().findBy(title: title, content: content, createdAt: createdAt)
    }

    static func filter(title: String = StringDefaultValue, content: String = StringDefaultValue, createdAt: Date = DateDefaultValue) -> ArticleRelation {
        return ArticleRelation().filter(title: title, content: content, createdAt: createdAt)
    }

    static func limit(length: UInt, offset: UInt = 0) -> ArticleRelation {
        return ArticleRelation().limit(length, offset: offset)
    }

    static func take(length: UInt) -> ArticleRelation {
        return ArticleRelation().limit(length)
    }

    static func offset(offset: UInt) -> ArticleRelation {
        return ArticleRelation().offset(offset)
    }

    static func groupBy(columns: Article.Column...) -> ArticleRelation {
        return ArticleRelation().groupBy(columns: columns)
    }

    static func groupBy(columns: [Article.Column]) -> ArticleRelation {
        return ArticleRelation().groupBy(columns: columns)
    }

    static func orderBy(column: Article.Column) -> ArticleRelation {
        return ArticleRelation().orderBy(column: column)
    }

    static func orderBy(column: Article.Column, asc: Bool) -> ArticleRelation {
        return ArticleRelation().orderBy(column: column, asc: asc)
    }
}

public extension ArticleRelation {
    func findBy(title: String = StringDefaultValue, content: String = StringDefaultValue, createdAt: Date = DateDefaultValue) -> Self {
        var attributes: [Article.Column: Any] = [:]
        if (title != StringDefaultValue) { attributes[.title] = title }
        if (content != StringDefaultValue) { attributes[.content] = content }
        if (createdAt != DateDefaultValue) { attributes[.createdAt] = createdAt }
        return self.filter(conditions: attributes)
    }

    func filter(title: String = StringDefaultValue, content: String = StringDefaultValue, createdAt: Date = DateDefaultValue) -> Self {
        return findBy(title: title, content: content, createdAt: createdAt)
    }

    func filter(conditions: [Article.Column: Any]) -> Self {
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

    func groupBy(columns: Article.Column...) -> Self {
        return self.groupBy(columns: columns)
    }

    func groupBy(columns: [Article.Column]) -> Self {
        func groupBy(column: Article.Column) {
            self.group.append("\(expandColumn(column))")
        }
        _ = columns.flatMap(groupBy)
        return self
    }

    func orderBy(column: Article.Column) -> Self {
        self.order.append("\(expandColumn(column))")
        return self
    }

    func orderBy(column: Article.Column, asc: Bool) -> Self {
        self.order.append("\(expandColumn(column)) \(asc ? "ASC" : "DESC")")
        return self
    }
}

// MARK: - Delete

public extension Article {
    var delete: Bool {
        get {
            let deleteSQL = "DELETE FROM \(Article.tableName) \(itself)"
            executeSQL(deleteSQL)
            return true
        }
    }
    static var deleteAll: Bool { get { return ArticleRelation().deleteAll } }
}

public extension ArticleRelation {
    var delete: Bool { get { return deleteAll } }

    var deleteAll: Bool {
        get {
            self.result.forEach { $0.delete }
            return true
        }
    }
}

public extension Article {
    static var count: Int {
        get {
            let countSQL = "SELECT count(*) FROM \(tableName)"
            guard let count = executeScalarSQL(countSQL) as? Int64 else { return 0 }
            return Int(count)
        }
    }
}

// MAKR: - Helper

open class ArticleRelation: Relation<Article> {
    override init() {
        super.init()
        self.select = "SELECT \(Article.tableName).* FROM \(Article.tableName)"
    }

    override var result: [Article] {
        get {
            return MetaModels.fromQuery(query)
        }
    }

    func expandColumn(_ column: Article.Column) -> String {
        return "\(Article.tableName).\(column)"
    }
}

extension Article {
    var itself: String { get { return "WHERE \(Article.tableName).private_id = \(privateId)" } }
}

extension ArticleRelation {
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
