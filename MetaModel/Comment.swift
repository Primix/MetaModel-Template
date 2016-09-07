//
//  Comment.swift
//  MetaModel
//
//  Created by Draveness on 8/22/16.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation

public struct Comment {
    public let id: Int
    public var content: String
    public var articleId: Int

    static let tableName = "comments"

    public enum Column: String, Unwrapped {
        case id = "id"
        case content = "content"
        case articleId = "articleId"

        var unwrapped: String { get { return self.rawValue.unwrapped } }
    }
}

extension Comment {
    public var article: Article! {
        mutating get {
            if self.article != nil { return article }
            article = Article.find(articleId)
            return article
        }
        set {
            article = newValue
        }
    }
}

extension Comment {
    public static func parse(json: [String: Any]) -> Comment {
        let id: Int = json["id"] as! Int
        let content: String = json["content"] as! String
        let article: Article = (json["author"] as? [String: Any]).flatMap(Article.parse)!
        var comment = Comment(id: id, content: content, articleId: article.id)
        comment.article = article
        return comment
    }

    public static func parse(jsons: [[String: Any]]) -> [Comment] {
        return jsons.map(Comment.parse)
    }

    public static func parse(data: NSData) throws -> Comment {
        let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String: Any]
        return Comment.parse(json)
    }

    public static func parses(data: NSData) throws -> [Comment] {
        let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [[String: Any]]
        return Comment.parse(json)
    }
}

extension Comment: Recordable {
    public init(values: Array<Optional<Binding>>) {
        let id: Int64 = values[0] as! Int64
        let content: String = values[1] as! String
        let articleId: Int64 = values[2] as! Int64
        self.init(id: Int(id), content: content, articleId: Int(articleId))
    }
}

extension Comment {
    static func initialize() {
        let createSQL = "CREATE TABLE \(tableName.unwrapped) (id INTEGER PRIMARY KEY NOT NULL, content TEXT, email TEXT NOT NULL);"
        executeSQL(createSQL);
    }

    static func deinitialize() {
        let dropTableSQL = "DROP TABLE \(tableName.unwrapped)"
        executeSQL(dropTableSQL)
    }
}

public extension Comment {
    static func deleteAll() {
        let deleteAllSQL = "DELETE FROM \(tableName.unwrapped)"
        executeSQL(deleteAllSQL)
    }
    static func count() -> Int {
        let countSQL = "SELECT count(*) FROM \(tableName.unwrapped)"
        guard let count = executeScalarSQL(countSQL) as? Int64 else { return 0 }
        return Int(count)
    }

    static func new(content: String, email: String, articleId: Int) -> Comment {
        return Comment(id: -1, content: content, articleId: articleId)
    }

    static func create(id: Int, content: String, articleId: Int) -> Comment? {
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

public extension Comment {
    var itself: String { get { return "WHERE \(Comment.tableName.unwrapped).\("id".unwrapped) = \(id)" } }

    func delete() {
        let deleteSQL = "DELETE FROM \(Comment.tableName.unwrapped) \(itself)"
        executeSQL(deleteSQL)
    }

    mutating func update(content content: String) -> Comment {
        return self.update([.content: content])
    }

    mutating func update(attributes: [Comment.Column: Any]) -> Comment {
        var setSQL: [String] = []
        for (key, _) in attributes {
            switch key {
            case .content: setSQL.append("\(key.unwrapped) = \(self.content.unwrapped)")
            default: break
            }
        }
        let updateSQL = "UPDATE \(Comment.tableName.unwrapped) SET \(setSQL.joinWithSeparator(", ")) \(itself)"
        executeSQL(updateSQL) {
            for (key, value) in attributes {
                switch key {
                case .content: self.content = value as! String
                default: break
                }
            }
        }
        return self
    }

    var save: Comment {
        get {
            Comment.create(id, content: content, articleId: articleId)
            return self
        }
    }
}

public extension Comment {
    static var all: CommentRelation {
        get { return CommentRelation() }
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

    static func findBy(id id: Int) -> Comment? {
        return CommentRelation().findBy(id: id).first
    }

    static func findBy(content content: String) -> Comment? {
        return CommentRelation().findBy(content: content).first
    }

    static func findBy(articleId articleId: Int) -> Comment? {
        return CommentRelation().findBy(articleId: articleId).first
    }

    static func filter(column: Comment.Column, value: Any) -> CommentRelation {
        return CommentRelation().filter([column: value])
    }

    static func filter(conditions: [Comment.Column: Any]) -> CommentRelation {
        return CommentRelation().filter(conditions)
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

public class CommentRelation: Relation<Comment> {
    override init() {
        super.init()
        self.select = "SELECT \(Comment.tableName.unwrapped).* FROM \(Comment.tableName.unwrapped)"
    }

    func expandColumn(column: Comment.Column) -> String {
        return "\(Comment.tableName.unwrapped).\(column.unwrapped)"
    }

    // MARK: Query

    public func find(id: Int) -> Self {
        return self.findBy(id: id)
    }

    public func findBy(id id: Int) -> Self {
        return self.filter([.id: id]).limit(1)
    }

    public func findBy(content content: String) -> Self {
        return self.filter([.content: content]).limit(1)
    }

    public func findBy(articleId articleId: Int) -> Self {
        return self.filter([.articleId: articleId]).limit(1)
    }

    public func filter(conditions: [Comment.Column: Any]) -> Self {
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

    public func groupBy(columns: Comment.Column...) -> Self {
        return self.groupBy(columns)
    }

    public func groupBy(columns: [Comment.Column]) -> Self {
        func groupBy(column: Comment.Column) {
            self.group.append("\(expandColumn(column))")
        }
        _ = columns.flatMap(groupBy)
        return self
    }

    public func orderBy(column: Comment.Column) -> Self {
        self.order.append("\(expandColumn(column))")
        return self
    }
    
    public func orderBy(column: Comment.Column, asc: Bool) -> Self {
        self.order.append("\(expandColumn(column)) \(asc ? "ASC".unwrapped : "DESC".unwrapped)")
        return self
    }
    
}


