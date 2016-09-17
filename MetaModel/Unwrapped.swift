//
//  Unwrapped
//  MetaModel
//
//  Created by Draveness on 9/3/16.
//  Copyright © 2016 metamodel. All rights reserved.
//

import Foundation

protocol Unwrapped {
    var unwrapped: String { get }
}

extension Unwrapped {
    var unwrapped: String {
        return "\(self)"
    }
}

extension Int: Unwrapped { }

extension Double: Unwrapped { }

extension Float: Unwrapped { }

extension Bool: Unwrapped { }

extension String: Unwrapped {
    var unwrapped: String {
        return "\"\(self)\""
    }
}

extension Date: Unwrapped {
    var unwrapped: String {
        return "\(self.timeIntervalSince1970)"
    }
}
