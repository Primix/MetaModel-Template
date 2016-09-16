//
//  Packing.swift
//  MetaModel
//
//  Created by Draveness on 9/16/16.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation

protocol Packing {
    init(values: Array<Optional<Binding>>);
}

class MetaModels {
    static func fromQuery<T where T: Packing>(query: String) -> [T] {
        var models: [T] = []
        guard let stmt = executeSQL(query) else { return models }
        for values in stmt {
            let association = T(values: values)
            models.append(association)
        }
        return models
    }
}

