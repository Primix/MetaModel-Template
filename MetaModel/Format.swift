//
//  Format.swift
//  MetaModel
//
//  Created by Draveness on 9/3/16.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation

extension Int {
    func format(f: String) -> String {
        return String(format: "%\(f)d", self)
    }
}

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}
