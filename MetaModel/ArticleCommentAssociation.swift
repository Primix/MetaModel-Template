//
//  ArticleCommentAssociation.swift
//  MetaModel
//
//  Created by Draveness on 9/14/16.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation

typealias CommentArticleAssociation = ArticleCommentAssociation

struct ArticleCommentAssociation {
    private var privateId: Int = 0
    private var articleId: Int = 0
    private var commentId: Int = 0

    static func findByArticleId(articleId: Int) -> [ArticleCommentAssociation] {
        let query = "SELECT * FROM \(tableName) WHERE article_id = \(articleId)"

        var models: [ArticleCommentAssociation] = []
        guard let stmt = executeSQL(query) else { return models }
        for values in stmt {
            let association = ArticleCommentAssociation(values: values)
            models.append(association)
        }
        return models
    }

    static func findByCommentId(commentId: Int) -> [ArticleCommentAssociation] {
        let query = "SELECT * FROM \(tableName) WHERE commentId = \(commentId)"

        var models: [ArticleCommentAssociation] = []
        guard let stmt = executeSQL(query) else { return models }
        for values in stmt {
            let association = ArticleCommentAssociation(values: values)
            models.append(association)
        }
        return models
    }
}

extension ArticleCommentAssociation {
    init(values: Array<Optional<Binding>>) {
        let privateId: Int64 = values[0] as! Int64
        let articleId: Int64 = values[1] as! Int64
        let commentId: Int64 = values[2] as! Int64

        self.init(privateId: Int(privateId), articleId: Int(articleId), commentId: Int(commentId))
    }
}

extension ArticleCommentAssociation {

    static let tableName = "article_comment_associations"
    static func initialize() {
        let initializeTableSQL = "CREATE TABLE \(tableName)(" +
        "private_id INTEGER PRIMARY KEY, " +
        "article_id INTEGER NOT NULL, " +
        "comment_id INTEGER NOT NULL, " +
        "FOREIGN KEY(article_id) REFERENCES articles(private_id)," +
        "FOREIGN KEY(comment_id) REFERENCES comments(private_id));"
        executeSQL(initializeTableSQL)
    }
    static func deinitialize() {
        let dropTableSQL = "DROP TABLE \(tableName.unwrapped)"
        executeSQL(dropTableSQL)
    }
}
