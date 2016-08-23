//
//  Person.swift
//  MetaModel
//
//  Created by 左书祺 on 8/22/16.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation
import SQLite

public struct Person {
    public let id: Int
    public var name: String? {
        didSet {
            try! db.run(itself.update(meta.name <- name))
        }
    }
    public var email: String {
        didSet {
            try! db.run(itself.update(meta.email <- email))
        }
    }
}

extension Person: Recordable {
    public init(record: SQLite.Row) {
        self.init(id: record[meta.id], name: record[meta.name], email: record[meta.email])
    }
}

extension Person {
    var itself: QueryType { get { return meta.table.filter(meta.id == self.id) } }

    struct meta {
        static let table = Table("people")
        static let id = Expression<Int>("id")
        static let name = Expression<String?>("name")
        static let email = Expression<String>("email")

        static func createTable() {
            let _ = try? db.run(table.create { t in
                t.column(id, primaryKey: true)
                t.column(name)
                t.column(email, unique: true)
            })
        }
    }
}

public extension Person {

    static func deleteAll() {
        let _ = try? db.run(meta.table.delete())
    }
    
    static func count() -> Int {
        return db.scalar(meta.table.count)
    }
    
    static func create(id: Int, name: String?, email: String) -> Person {
        let insert = meta.table.insert(meta.id <- id, meta.name <- name, meta.email <- email)
        let _ = try? db.run(insert)
        return Person(id: id, name: name, email: email)
    }
    
}


public extension Person {
    func delete() {
        try! db.run(itself.delete())
    }

    mutating func update(name name: String?) -> Person {
        self.name = name
        return self
    }

    mutating func update(email email: String) -> Person {
        self.email = email
        return self
    }

    static func findBy(id id: Int) -> Person? {
        for record in try! db.prepare(meta.table.filter(meta.id == id)) {
            return Person(record: record)
        }
        return nil
    }
}

public extension Person {
    static private func findAll(query: QueryType) -> [Person] {
        var result: [Person] = []
        for record in try! db.prepare(query) {
            result.append(Person(record: record))
        }
        return result
    }

    static var all: [Person] {
        get {
            var result: [Person] = []
            for record in try! db.prepare(meta.table) {
                result.append(Person(record: record))
            }
            return result
        }
    }

    static func findBy(name name: String) -> [Person] {
        return findAll(meta.table.filter(meta.name == name))
    }
    
    static func findBy(email email: String) -> [Person] {
        return findAll(meta.table.filter(meta.email == email))
    }
}
