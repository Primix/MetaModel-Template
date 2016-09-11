//
//  Constructor.swift
//  MetaModel
//
//  Created by Draveness on 9/9/16.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation

extension NSDate {
    convenience init(_ secs: Double) {
        self.init(timeIntervalSince1970: secs)
    }
}

extension Bool {
    init<T : IntegerType>(_ integer: T) {
        if integer == 0 {
            self.init(false)
        } else {
            self.init(true)
        }
    }
}