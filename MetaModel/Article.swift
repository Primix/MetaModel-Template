//
//  Article.swift
//  MetaModel
//
//  Created by Draveness on 8/22/16.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation

public struct Article {
    public let id: Int
    public var title: String

    static let tableName = "articles"

    public enum Column: String, Unwrapped {
        case id = "id"
        case title = "title"

        var unwrapped: String { get { return self.rawValue.unwrapped } }
    }
}

extension Article {
    public static func parse(json: [String: Any]) -> Article {
        let id: Int = json["id"] as! Int
        let title: String = json["title"] as! String
        return Article(id: id, title: title)
    }

    public static func parse(jsons: [[String: Any]]) -> [Article] {
        var results: [Article] = []
        for json in jsons {
            results.append(Article.parse(json))
        }
        return results
    }

    public static func parse(data: NSData) throws -> Article {
        let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String: Any]
        return Article.parse(json)
    }

    public static func parses(data: NSData) throws -> [Article] {
        let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [[String: Any]]
        return Article.parse(json)
    }
}

extension Article: Recordable {
    public init(values: Array<Optional<Binding>>) {
        let id: Int64 = values[0] as! Int64
        let title: String = values[1] as! String
        self.init(id: Int(id), title: title)
    }
}

extension Article {
    static func initialize() {
        let createSQL = "CREATE TABLE \(tableName.unwrapped) (id INTEGER PRIMARY KEY NOT NULL, title TEXT);"
        executeSQL(createSQL);
    }

    static func deinitialize() {
        let dropTableSQL = "DROP TABLE \(tableName.unwrapped)"
        executeSQL(dropTableSQL)
    }
}

public extension Article {
    static func deleteAll() {
        let deleteAllSQL = "DELETE FROM \(tableName.unwrapped)"
        executeSQL(deleteAllSQL)
    }
    static func count() -> Int {
        let countSQL = "SELECT count(*) FROM \(tableName.unwrapped)"
        guard let count = executeScalarSQL(countSQL) as? Int64 else { return 0 }
        return Int(count)
    }

    static func new(title: String, email: String) -> Article {
        return Article(id: -1, title: title)
    }

    static func create(id: Int, title: String) -> Article? {
        var columnsSQL: [Article.Column] = []
        var valuesSQL: [Unwrapped] = []

        columnsSQL.append(.id)
        valuesSQL.append(id)

        columnsSQL.append(.title)
        valuesSQL.append(title)

        let insertSQL = "INSERT INTO \(tableName.unwrapped) (\(columnsSQL.map { $0.rawValue }.joinWithSeparator(", "))) VALUES (\(valuesSQL.map { $0.unwrapped }.joinWithSeparator(", ")))"
        guard let _ = executeSQL(insertSQL) else { return nil }
        return Article(id: id, title: title)
    }
}

public extension Article {
    var itself: String { get { return "WHERE \(Article.tableName.unwrapped).\("id".unwrapped) = \(id)" } }

    func delete() {
        let deleteSQL = "DELETE FROM \(Article.tableName.unwrapped) \(itself)"
        executeSQL(deleteSQL)
    }

    mutating func update(title title: String) -> Article {
        return self.update([.title: title])
    }

    mutating func update(attributes: [Article.Column: Any]) -> Article {
        var setSQL: [String] = []
        for (key, _) in attributes {
            switch key {
            case .title: setSQL.append("\(key.unwrapped) = \(self.title.unwrapped)")
            default: break
            }
        }
        let updateSQL = "UPDATE \(Article.tableName.unwrapped) SET \(setSQL.joinWithSeparator(", ")) \(itself)"
        executeSQL(updateSQL) {
            for (key, value) in attributes {
                switch key {
                case .title: self.title = value as! String
                default: break
                }
            }
        }
        return self
    }

    var save: Article {
        get {
            Article.create(id, title: title)
            return self
        }
    }
}

public extension Article {
    static var all: ArticleRelation {
        get { return ArticleRelation() }
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

    static func findBy(id id: Int) -> Article? {
        return ArticleRelation().findBy(id: id).first
    }

    static func findBy(title title: String) -> Article? {
        return ArticleRelation().findBy(title: title).first
    }

    static func filter(column: Article.Column, value: Any) -> ArticleRelation {
        return ArticleRelation().filter([column: value])
    }

    static func filter(conditions: [Article.Column: Any]) -> ArticleRelation {
        return ArticleRelation().filter(conditions)
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

public class ArticleRelation: Relation<Article> {
    override init() {
        super.init()
        self.select = "SELECT \(Article.tableName.unwrapped).* FROM \(Article.tableName.unwrapped)"
    }

    func expandColumn(column: Article.Column) -> String {
        return "\(Article.tableName.unwrapped).\(column.unwrapped)"
    }

    // MARK: Query

    public func find(id: Int) -> Self {
        return self.findBy(id: id)
    }

    public func findBy(id id: Int) -> Self {
        return self.filter([.id: id]).limit(1)
    }

    public func findBy(title title: String) -> Self {
        return self.filter([.title: title]).limit(1)
    }

    public func filter(conditions: [Article.Column: Any]) -> Self {
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

    public func groupBy(columns: Article.Column...) -> Self {
        return self.groupBy(columns)
    }

    public func groupBy(columns: [Article.Column]) -> Self {
        func groupBy(column: Article.Column) {
            self.group.append("\(expandColumn(column))")
        }
        _ = columns.flatMap(groupBy)
        return self
    }

    public func orderBy(column: Article.Column) -> Self {
        self.order.append("\(expandColumn(column))")
        return self
    }
    
    public func orderBy(column: Article.Column, asc: Bool) -> Self {
        self.order.append("\(expandColumn(column)) \(asc ? "ASC".unwrapped : "DESC".unwrapped)")
        return self
    }
    
}

public extension Article {
    var comments: [Comment] {
        get {
            return Comment.filter(.id, value: id).result
        }
    }
    
    func buildComment(id: Int, content: String) -> Comment? {
        return Comment.create(id, content: content, articleId: self.id)
    }
}
