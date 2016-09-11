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
        let initializeTableSQL = "CREATE TABLE articles(_id INTEGER PRIMARY KEY, id INTEGER UNIQUE DEFAULT 0, title TEXT, content TEXT, createdAt REAL);"
        executeSQL(initializeTableSQL)
    }
    static func deinitialize() {
        let dropTableSQL = "DROP TABLE \(tableName.unwrapped)"
        executeSQL(dropTableSQL)
    }
}

public struct Article {
    public var id: Int
    public var title: String
    public var content: String
    public var createdAt: NSDate
    
    static let tableName = "articles"

    public enum Column: String, Unwrapped {
        case id = "id"
        case title = "title"
        case content = "content"
        case createdAt = "createdAt"
        
        var unwrapped: String { get { return self.rawValue.unwrapped } }
    }

    public init(id: Int = 0, title: String, content: String, createdAt: NSDate) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        
    }

    static public func new(id id: Int = 0, title: String, content: String, createdAt: NSDate) -> Article {
        return Article(id: id, title: title, content: content, createdAt: createdAt)
    }

    static public func create(id id: Int = 0, title: String, content: String, createdAt: NSDate) -> Article? {
        if id == 0 { return nil }

        var columnsSQL: [Article.Column] = []
        var valuesSQL: [Unwrapped] = []

        columnsSQL.append(.id)
        valuesSQL.append(id)
        
        columnsSQL.append(.title)
        valuesSQL.append(title)
        
        columnsSQL.append(.content)
        valuesSQL.append(content)
        
        columnsSQL.append(.createdAt)
        valuesSQL.append(createdAt)
        
        let insertSQL = "INSERT INTO \(tableName.unwrapped) (\(columnsSQL.map { $0.rawValue }.joinWithSeparator(", "))) VALUES (\(valuesSQL.map { $0.unwrapped }.joinWithSeparator(", ")))"
        guard let _ = executeSQL(insertSQL) else { return nil }
        return Article(id: id, title: title, content: content, createdAt: createdAt)
    }
}

// MARK: - Update

public extension Article {
    mutating func update(title title: String = StringDefaultValue, content: String = StringDefaultValue, createdAt: NSDate = NSDateDefaultValue) -> Article {
        var attributes: [Article.Column: Any] = [:]
        if (title != StringDefaultValue) { attributes[.title] = title }
        if (content != StringDefaultValue) { attributes[.content] = content }
        if (createdAt != NSDateDefaultValue) { attributes[.createdAt] = createdAt }
        return self.update(attributes)
    }

    mutating func update(attributes: [Article.Column: Any]) -> Article {
        var setSQL: [String] = []
        if let attributes = attributes as? [Article.Column: Unwrapped] {
            for (key, value) in attributes {
                switch key {
                case .title: setSQL.append("\(key.unwrapped) = \(value.unwrapped)")
                case .content: setSQL.append("\(key.unwrapped) = \(value.unwrapped)")
                case .createdAt: setSQL.append("\(key.unwrapped) = \(value.unwrapped)")
                default: break
                }
            }
            let updateSQL = "UPDATE \(Article.tableName.unwrapped) SET \(setSQL.joinWithSeparator(", ")) \(itself)"
            executeSQL(updateSQL) {
                for (key, value) in attributes {
                    switch key {
                    case .title: self.title = value as! String
                    case .content: self.content = value as! String
                    case .createdAt: self.createdAt = value as! NSDate
                    default: break
                    }
                }
            }
        }
        return self
    }

    var save: Article {
        mutating get {
            if let _ = Article.find(id) {
                update([.id: id, .title: title, .content: content, .createdAt: createdAt])
            } else {
                Article.create(id: id, title: title, content: content, createdAt: createdAt)
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
    public func updateAll(column: Article.Column, value: Any) {
        self.result.forEach { (element) in
            var element = element
            element.update([column: value])
        }
    }
}

// MARK: - Query

public extension Article {
    static var all: ArticleRelation {
        get { return ArticleRelation() }
    }

    static var first: Article? {
        get {
            return ArticleRelation().orderBy(.id, asc: true).first
        }
    }

    static var last: Article? {
        get {
            return ArticleRelation().orderBy(.id, asc: false).first
        }
    }

    static func first(length: UInt) -> ArticleRelation {
        return ArticleRelation().orderBy(.id, asc: true).limit(length)
    }

    static func last(length: UInt) -> ArticleRelation {
        return ArticleRelation().orderBy(.id, asc: false).limit(length)
    }

    static func find(id: Int) -> Article? {
        return ArticleRelation().find(id).first
    }

    static func findBy(id id: Int = IntDefaultValue, title: String = StringDefaultValue, content: String = StringDefaultValue, createdAt: NSDate = NSDateDefaultValue) -> ArticleRelation {
        var attributes: [Article.Column: Any] = [:]
        if (id != IntDefaultValue) { attributes[.id] = id }
        if (title != StringDefaultValue) { attributes[.title] = title }
        if (content != StringDefaultValue) { attributes[.content] = content }
        if (createdAt != NSDateDefaultValue) { attributes[.createdAt] = createdAt }
        return ArticleRelation().filter(attributes)
    }

    static func filter(id id: Int = IntDefaultValue, title: String = StringDefaultValue, content: String = StringDefaultValue, createdAt: NSDate = NSDateDefaultValue) -> ArticleRelation {
        return findBy(id: id, title: title, content: content, createdAt: createdAt)
    }

    static func limit(length: UInt, offset: UInt = 0) -> ArticleRelation {
        return ArticleRelation().limit(length, offset: offset)
    }

    static func take(length: UInt) -> ArticleRelation {
        return limit(length)
    }

    static func offset(offset: UInt) -> ArticleRelation {
        return ArticleRelation().offset(offset)
    }

    static func groupBy(columns: Article.Column...) -> ArticleRelation {
        return ArticleRelation().groupBy(columns)
    }

    static func groupBy(columns: [Article.Column]) -> ArticleRelation {
        return ArticleRelation().groupBy(columns)
    }

    static func orderBy(column: Article.Column) -> ArticleRelation {
        return ArticleRelation().orderBy(column)
    }

    static func orderBy(column: Article.Column, asc: Bool) -> ArticleRelation {
        return ArticleRelation().orderBy(column, asc: asc)
    }
}

public extension ArticleRelation {
    func find(id: Int) -> Self {
        return findBy(id: id)
    }

    func findBy(id id: Int = IntDefaultValue, title: String = StringDefaultValue, content: String = StringDefaultValue, createdAt: NSDate = NSDateDefaultValue) -> Self {
        var attributes: [Article.Column: Any] = [:]
        if (id != IntDefaultValue) { attributes[.id] = id }
        if (title != StringDefaultValue) { attributes[.title] = title }
        if (content != StringDefaultValue) { attributes[.content] = content }
        if (createdAt != NSDateDefaultValue) { attributes[.createdAt] = createdAt }
        return self.filter(attributes)
    }

    func filter(id id: Int = IntDefaultValue, title: String = StringDefaultValue, content: String = StringDefaultValue, createdAt: NSDate = NSDateDefaultValue) -> Self {
        return findBy(id: id, title: title, content: content, createdAt: createdAt)
    }

    func filter(conditions: [Article.Column: Any]) -> Self {
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

    func groupBy(columns: Article.Column...) -> Self {
        return self.groupBy(columns)
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
        self.order.append("\(expandColumn(column)) \(asc ? "ASC".unwrapped : "DESC".unwrapped)")
        return self
    }
}

// MARK: - Delete

public extension Article {
    var delete: Bool {
        get {
            let deleteSQL = "DELETE FROM \(Article.tableName.unwrapped) \(itself)"
            executeSQL(deleteSQL)
            return true
        }
    }
    static func deleteAll() {
        let deleteAllSQL = "DELETE FROM \(tableName.unwrapped)"
        executeSQL(deleteAllSQL)
    }
}

public extension ArticleRelation {
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
            let countSQL = "SELECT count(*) FROM \(tableName.unwrapped)"
            guard let count = executeScalarSQL(countSQL) as? Int64 else { return 0 }
            return Int(count)
        }
    }
}

// MARK: - Association

public extension Article {
    func appendComment(element: Comment) {
        var element = element
        element.update(articleId: id)
    }

    func createComment(id id: Int = 0, content: String) -> Comment? {
        return Comment.create(id: id, content: content, articleId: self.id)
    }

    func deleteComment(id: Int) {
        Comment.findBy(articleId: id).first?.delete
    }
    var comments: [Comment] {
        get {
            return Comment.filter(id: id).result
        }
        set {
            comments.forEach { (element) in
                var element = element
                element.update(articleId: 0)
            }
            newValue.forEach { (element) in
                var element = element
                element.update(articleId: id)
            }
        }
    }
}

// MAKR: - Helper

public class ArticleRelation: Relation<Article> {
    override init() {
        super.init()
        self.select = "SELECT \(Article.tableName.unwrapped).* FROM \(Article.tableName.unwrapped)"
    }

    override var result: [Article] {
        get {
            var models: [Article] = []
            guard let stmt = executeSQL(query) else { return models }
            for values in stmt {
                models.append(Article(values: values))
            }
            return models
        }
    }

    func expandColumn(column: Article.Column) -> String {
        return "\(Article.tableName.unwrapped).\(column.unwrapped)"
    }
}

extension Article {
    init(values: Array<Optional<Binding>>) {
        let id: Int64 = values[1] as! Int64
        let title: String = values[2] as! String
        let content: String = values[3] as! String
        let createdAt: Double = values[4] as! Double
        
        self.init(id: Int(id), title: String(title), content: String(content), createdAt: NSDate(createdAt))
    }
}

extension Article {
    var itself: String { get { return "WHERE \(Article.tableName.unwrapped).\("id".unwrapped) = \(id)" } }
}
