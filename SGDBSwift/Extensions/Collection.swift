//
//  Collection.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 5/29/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
