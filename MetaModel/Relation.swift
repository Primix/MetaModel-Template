//
//  Relation.swift
//  MetaModel
//
//  Created by 左书祺 on 8/23/16.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation
import SQLite

//public struct Relation<T: Recordable> {
//    
//    let db: Connection
//    var query: QueryType
//    var result: [T] = []
//    
//    subscript(index: Int) -> T {
//        mutating get {
//            if result.count == 0 {
//                for record in try! db.prepare(query) {
//                    result.append(T(record: record))
//                }
//            }
//            return result[index]
//        }
//    }
//    
//    func filter(query: QueryType) -> Relation<T> {
//        
//        return self
//    }
//}

public struct Relation<T: Recordable> {
    
    var query: QueryType
    var result: [T] = []
    
    subscript(index: Int) -> T {
        mutating get {
            if result.count == 0 {
                for record in try! db.prepare(query) {
                    result.append(T(record: record))
                }
            }
            return result[index]
        }
    }
    
    func filter(query: QueryType) -> Relation<T> {
        
        return self
    }
}

