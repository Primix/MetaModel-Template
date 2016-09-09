//
//  ViewController.swift
//  MetaModel iOS Example
//
//  Created by 左书祺 on 9/9/16.
//  Copyright © 2016 metamodel. All rights reserved.
//

import UIKit
import MetaModel

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Person.create(1, name: "Draven", email: "stark.draven@gmail.com")
        
        print(Person.all)
    }


}

