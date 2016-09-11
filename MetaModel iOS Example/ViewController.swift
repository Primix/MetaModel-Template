//
//  ViewController.swift
//  MetaModel iOS Example
//
//  Created by Draveness on 9/9/16.
//  Copyright © 2016 metamodel. All rights reserved.
//

import UIKit
import MetaModel

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Article.create(id: 1, title: "TItle", content: "Hello", createdAt: NSDate())

        for article in Article.all {
            print(article)
        }
    }


}

