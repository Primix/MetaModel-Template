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
    static let table = Table("people")

    var itself: QueryType { get { return Person.table.filter(meta.id == self.id) } }

    struct meta {
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
        let _ = try? db.run(Person.table.delete())
    }
    
    static func count() -> Int {
        return db.scalar(Person.table.count)
    }
    
    static func create(id: Int, name: String?, email: String) -> Person {
        let insert = Person.table.insert(meta.id <- id, meta.name <- name, meta.email <- email)
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
        for record in try! db.prepare(Person.table.filter(meta.id == id)) {
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

    static var all: PersonRelation {
        get {
            return PersonRelation(query: Person.table)
        }
    }

    static func findBy(name name: String) -> PersonRelation {
        return PersonRelation(query: Person.table.filter(meta.name == name))
    }
    
    static func findBy(email email: String) -> PersonRelation {
        return PersonRelation(query: Person.table.filter(meta.email == email))
    }

    static func limit(length: Int, offset: Int = 0) -> PersonRelation {
        return PersonRelation(query: Person.table.limit(length, offset: offset))
    }
}

public class PersonRelation: Relation<Person> {
    override init(query: QueryType) {
        super.init(query: query)
    }

    var all: PersonRelation {
        get {
            return self
        }
    }

    func findBy(name name: String) -> Self {
        query = query.filter(Person.meta.name == name)
        return self
    }

    func findBy(email email: String) -> Self {
        query = query.filter(Person.meta.email == email)
        return self
    }

    func limit(length: Int, offset: Int = 0) -> Self {
        query = query.limit(length, offset: offset)
        return self
    }

}
