//
//  Person.swift
//  MetaModel
//
//  Created by Draveness on 8/22/16.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation
import SQLite

public struct Person {
    public let id: Int
    public var name: String?
    public var email: String

    public enum Represent: String {
        case id = "id"
        case name = "name"
        case email = "email"
    }
}

extension Person: Recordable {
    public init(values: Array<Optional<Binding>>) {
        let id: Int64 = values[0] as! Int64
        let name: String? = values[1] as? String
        let email: String = values[2] as! String
        self.init(id: Int(id), name: name, email: email)
    }
}

extension Person {
    static let table = Table("people")

    static let tableName = "people"

    public static let id = Expression<Int>("id")
    public static let name = Expression<String?>("name")
    public static let email = Expression<String>("email")

    var itself: QueryType { get { return Person.table.filter(Person.id == self.id) } }

    static func createTable() {
        let _ = try? db.run(table.create { t in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(email)
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
}

public extension Person {
    static var all: PersonRelation {
        get { return PersonRelation() }
    }

    static func find(id: Int) -> Person? {
        return PersonRelation().find(id).first
    }

    static func findBy(id id: Int) -> Person? {
        return PersonRelation().findBy(id: id).first
    }

    static func findBy(name name: String) -> Person? {
        return PersonRelation().findBy(name: name).first
    }
    
    static func findBy(email email: String) -> Person? {
        return PersonRelation().findBy(email: email).first
    }

    static func filter(column: Person.Represent, value: Any) -> PersonRelation {
        return PersonRelation().filter([column: value])
    }

    static func filter(conditions: [Person.Represent: Any]) -> PersonRelation {
        return PersonRelation().filter(conditions)
    }

    static func limit(length: UInt, offset: UInt = 0) -> PersonRelation {
        return PersonRelation().limit(length, offset: offset)
    }

    static func offset(offset: UInt) -> PersonRelation {
        return PersonRelation().offset(offset)
    }

    static func groupBy(column: Person.Represent) -> PersonRelation {
        return PersonRelation().groupBy(column)
    }

    static func groupBy(column: Person.Represent, asc: Bool) -> PersonRelation {
        return PersonRelation().groupBy(column, asc: asc)
    }
}

public class PersonRelation: Relation<Person> {
    override init() {
        super.init()
        self.select = "SELECT \(Person.tableName.quotes).* FROM \(Person.tableName.quotes)"
    }

    public func filter(conditions: [Person.Represent: Any]) -> Self {
        for (column, value) in conditions {
            let columnSQL = "\(Person.tableName.quotes).\(column.rawValue.quotes)"

            func filterByEqual(value: Any) {
                self.filter.append("\(columnSQL) = \(value)")
            }

            func filterByIn(value: [String]) {
                self.filter.append("\(columnSQL) IN (\(value.joinWithSeparator(", ")))")
            }

            if let value = value as? String {
                filterByEqual(value.quotes)
            } else if let value = value as? Int {
                filterByEqual(value)
            } else if let value = value as? Double {
                filterByEqual(value)
            } else if let value = value as? [String] {
                filterByIn(value.map { $0.quotes })
            } else if let value = value as? [Int] {
                filterByIn(value.map { $0.description })
            } else if let value = value as? [Double] {
                filterByIn(value.map { $0.description })
            } else {
                let valueMirror = Mirror(reflecting: value)
                print("!!!: WRONG TYPE \(valueMirror.subjectType)")
            }

        }
        return self
    }

    public func find(id: Int) -> Self {
        return self.findBy(id: id)
    }

    public func findBy(id id: Int) -> Self {
        return self.filter([.id: id]).limit(1)
    }

    public func findBy(name name: String) -> Self {
        return self.filter([.name: name]).limit(1)
    }

    public func findBy(email email: String) -> Self {
        return self.filter([.email: email]).limit(1)
    }

    public func offset(offset: UInt) -> Self {
        self.offset = "OFFSET \(offset)"
        return self
    }

    public func limit(length: UInt, offset: UInt = 0) -> Self {
        self.limit = "LIMIT \(length)"
        if offset != 0 {
            self.offset = "OFFSET \(offset)"
        }
        return self
    }

    public func groupBy(column: Person.Represent) -> Self {
        self.group.append("\(Person.tableName.quotes).\(column.rawValue.quotes)")
        return self
    }

    public func groupBy(column: Person.Represent, asc: Bool) -> Self {
        self.group.append("\(Person.tableName.quotes).\(column.rawValue.quotes) \(asc ? "ASC".quotes : "DESC".quotes)")
        return self
    }

}


