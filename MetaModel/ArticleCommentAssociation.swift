//
//  ArticleCommentAssociation.swift
//  MetaModel
//
//  Created by MetaModel.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation

typealias CommentArticleAssociation = ArticleCommentAssociation

struct ArticleCommentAssociation {
    var privateId: Int = 0
    var articleId: Int = 0
    var commentId: Int = 0

    enum Association: String, CustomStringConvertible {
        case privateId = "private_id"
        case articleId = "article_id"
        case commentId = "comment_id"
        var description: String { get { return self.rawValue } }
    }
    
    static func fetchArticles(commentId: Int, first: Bool = false) -> [Article] {
        var query = "SELECT * FROM articles WHERE articles.private_id IN (" +
            "SELECT private_id " +
            "FROM \(tableName) " +
            "WHERE \(Association.commentId) = \(commentId)" +
        ")"
        if first { query += "LIMIT 1" }
        return MetaModels.fromQuery(query)
    }
    
    static func fetchComments(articleId: Int, first: Bool = false) -> [Comment] {
        var query = "SELECT * FROM comments WHERE comments.private_id IN (" +
            "SELECT private_id " +
            "FROM \(tableName) " +
            "WHERE \(Association.articleId) = \(articleId)" +
        ")"
        if first { query += "LIMIT 1" }
        return MetaModels.fromQuery(query)
    }
    
    static func findBy(articleId: Int) -> [ArticleCommentAssociation] {
        let query = "SELECT * FROM \(tableName) WHERE article_id = \(articleId)"
        return MetaModels.fromQuery(query)
    }
    
    static func findBy(commentId: Int) -> [ArticleCommentAssociation] {
        let query = "SELECT * FROM \(tableName) WHERE comment_id = \(commentId)"
        return MetaModels.fromQuery(query)
    }
    
    @discardableResult func delete() {
        executeSQL("DELETE * FROM \(ArticleCommentAssociation.tableName) WHERE private_id = \(privateId)")
    }
}

extension ArticleCommentAssociation {
    static func create(articleId: Int, commentId: Int) {
        executeSQL("INSERT INTO \(ArticleCommentAssociation.tableName) (article_id, comment_id) VALUES (\(articleId), \(commentId))")
    }
}

extension ArticleCommentAssociation {
    static let tableName = "article_comment_association"
    static func initialize() {
        let initializeTableSQL = "CREATE TABLE \(tableName)(" +
          "private_id INTEGER PRIMARY KEY, " +
          "article_id INTEGER NOT NULL, " +
          "comment_id INTEGER NOT NULL, " +
          "FOREIGN KEY(article_id) REFERENCES articles(private_id)," +
          "FOREIGN KEY(comment_id) REFERENCES comments(private_id)" +
        ");"

        executeSQL(initializeTableSQL)
        initializeTrigger()
    }

    static func deinitialize() {
        let dropTableSQL = "DROP TABLE \(tableName)"
        executeSQL(dropTableSQL)
        deinitializeTrigger()
    }

    static func initializeTrigger() {
        let majorDeleteTrigger = "CREATE TRIGGER article_delete_trigger " +
            "AFTER DELETE ON articles " +
            "FOR EACH ROW BEGIN " +
                "DELETE FROM \(tableName) WHERE private_id = OLD.private_id; " +
            "END;";

        let secondaryDeleteTrigger = "CREATE TRIGGER comment_delete_trigger " +
            "AFTER DELETE ON comments " +
            "FOR EACH ROW BEGIN " +
                "DELETE FROM \(tableName) WHERE private_id = OLD.private_id; " +
            "END;";

        executeSQL(majorDeleteTrigger)
        executeSQL(secondaryDeleteTrigger)
    }

    static func deinitializeTrigger() {
        let dropMajorTrigger = "DROP TRIGGER IF EXISTS article_delete_trigger;"
        executeSQL(dropMajorTrigger)

        let dropSecondaryTrigger = "DROP TRIGGER IF EXISTS comment_delete_trigger;"
        executeSQL(dropSecondaryTrigger)
    }
}

public extension Article {
    var comments: [Comment] {
        get {
            return ArticleCommentAssociation.fetchComments(articleId: privateId)
        }
        set {
            ArticleCommentAssociation.findBy(articleId: privateId).forEach { $0.delete() }
            newValue.forEach { ArticleCommentAssociation.create(articleId: privateId, commentId: $0.privateId) }
        }
    }

    @discardableResult func createComment(content: String) -> Comment? {
        guard let result = Comment.create(content: content) else { return nil }
        ArticleCommentAssociation.create(articleId: privateId, commentId: result.privateId)
        return result
    }

    @discardableResult func appendComment(content: String) -> Comment? {
        return createComment(content: content)
    }
}
