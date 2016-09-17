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
    static func fromQuery<T>(_ query: String) -> [T] where T: Packing {
        var models: [T] = []
        guard let stmt = executeSQL(query) else { return models }
        for values in stmt {
            let association = T(values: values)
            models.append(association)
        }
        return models
    }
}

// MARK: - Model Packing

extension Article: Packing {
    init(values: Array<Optional<Binding>>) {
        let title: String = values[1] as! String
        let content: String = values[2] as! String
        let createdAt: Double = values[3] as! Double

        self.init(title: String(title), content: String(content), createdAt: Date(createdAt))

        let privateId: Int64 = values[0] as! Int64
        self.privateId = Int(privateId)
    }
}

extension Comment: Packing {
    init(values: Array<Optional<Binding>>) {
        let content: String = values[1] as! String

        self.init(content: String(content))

        let privateId: Int64 = values[0] as! Int64
        self.privateId = Int(privateId)
    }
}


// MARK: - Association Packing

extension ArticleCommentAssociation: Packing {
    init(values: Array<Optional<Binding>>) {
        let privateId: Int64 = values[0] as! Int64
        let articleId: Int64 = values[1] as! Int64
        let commentId: Int64 = values[2] as! Int64

        self.init(privateId: Int(privateId), articleId: Int(articleId), commentId: Int(commentId))
    }
}

