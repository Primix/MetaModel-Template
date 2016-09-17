//
//  CommentArticleAssociation.swift
//  MetaModel
//
//  Created by MetaModel.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation

extension CommentArticleAssociation {
    @discardableResult static func create(commentId: Int, articleId: Int) {
        executeSQL("INSERT INTO \(CommentArticleAssociation.tableName) (comment_id, article_id) VALUES (\(commentId), \(articleId))")
    }
}

public extension Comment {
    var article: Article? {
        get {
            guard let id = CommentArticleAssociation.findBy(commentId: privateId).first?.commentId else { return nil }
            return Article.find(id)
        }
        set {
            guard let newValue = newValue else { return }
            CommentArticleAssociation.findBy(commentId: privateId).forEach { $0.delete() }
            CommentArticleAssociation.create(commentId: newValue.privateId, articleId: privateId)
        }
    }
}
