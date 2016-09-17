//
//  MetaModel.swift
//  MetaModel
//
//  Created by MetaModel.
//  Copyright © 2016 MetaModel. All rights reserved.
//

import Foundation

public class MetaModel {
    public static func initialize() {
        validateMetaModelTables()
    }
    static func validateMetaModelTables() {
        createMetaModelTable()
        let infos = retrieveMetaModelTableInfos()
        if infos[Article.tableName] != "21a8ff4814819041" {
            updateMetaModelTableInfos(Article.tableName, hashValue: "21a8ff4814819041")
            Article.deinitialize()
            Article.initialize()
        }
        if infos[Comment.tableName] != "d198ba9b2906f4d" {
            updateMetaModelTableInfos(Comment.tableName, hashValue: "d198ba9b2906f4d")
            Comment.deinitialize()
            Comment.initialize()
        }


        if infos[ArticleCommentAssociation.tableName] != "1ea29bc5cdd2fa60" {
            updateMetaModelTableInfos(ArticleCommentAssociation.tableName, hashValue: "1ea29bc5cdd2fa60")
            ArticleCommentAssociation.deinitialize()
            ArticleCommentAssociation.initialize()
        }

    }
}
