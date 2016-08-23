//
//  Person.swift
//  MetaModel
//
//  Created by Draveness on 8/22/16.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation
import SQLite

public enum PersonAttribute {
    case id
    case name
    case email
}

public struct Person {
    public let id: Int
    public var name: String? {
        didSet {
            try! db.run(itself.update(Person.name <- name))
        }
    }
    public var email: String {
        didSet {
            try! db.run(itself.update(Person.email <- email))
        }
    }
}

extension Person: Recordable {
    public init(record: SQLite.Row) {
        self.init(id: record[Person.id], name: record[Person.name], email: record[Person.email])
    }
}

extension Person {
    static let table = Table("people")
    static let id = Expression<Int>("id")
    static let name = Expression<String?>("name")
    static let email = Expression<String>("email")

    var itself: QueryType { get { return Person.table.filter(Person.id == self.id) } }

    static func createTable() {
        let _ = try? db.run(table.create { t in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(email, unique: true)
        })
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
        let insert = Person.table.insert(Person.id <- id, Person.name <- name, Person.email <- email)
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
        for record in try! db.prepare(Person.table.filter(Person.id == id)) {
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
            return PersonRelation()
        }
    }

    static func findBy(name name: String) -> PersonRelation {
        return PersonRelation().findBy(name: name)
    }
    
    static func findBy(email email: String) -> PersonRelation {
        return PersonRelation().findBy(email: email)
    }

    static func limit(length: Int, offset: Int = 0) -> PersonRelation {
        return PersonRelation().limit(length, offset: offset)
    }

    static func group(params: [PersonAttribute: Order]) -> PersonRelation {
        return PersonRelation().group(params)
    }
}

public class PersonRelation: Relation<Person> {
    init() {
        super.init(query: Person.table)
    }

    public func findBy(name name: String) -> Self {
        query = query.filter(Person.name == name)
        return self
    }

    public func findBy(email email: String) -> Self {
        query = query.filter(Person.email == email)
        return self
    }

    public func limit(length: Int, offset: Int = 0) -> Self {
        query = query.limit(length, offset: offset)
        return self
    }

    func group(params: [PersonAttribute: Order]) -> Self {
        var expressions: [Expressible] = []
        for param in params {
            switch (param.0, param.1) {
            case (.id, .DESC):
                expressions.append(Person.id.desc)
            case (.id, .ASC):
                expressions.append(Person.id.asc)
            case (.name, .DESC):
                expressions.append(Person.name.desc)
            case (.name, .ASC):
                expressions.append(Person.name.asc)
            case (.email, .DESC):
                expressions.append(Person.email.desc)
            case (.email, .ASC):
                expressions.append(Person.email.asc)
            default:
                break
            }
        }
//        query = query.filter(<#T##predicate: Expression<Bool>##Expression<Bool>#>)
        return self
    }

}
