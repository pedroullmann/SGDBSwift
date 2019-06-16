//
//  DeadlockCellViewModel.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 6/16/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import Foundation

class DeadlockCellViewModel {
    var deadlock: Deadlock
    
    init(deadlock: Deadlock) {
        self.deadlock = deadlock
    }
}
