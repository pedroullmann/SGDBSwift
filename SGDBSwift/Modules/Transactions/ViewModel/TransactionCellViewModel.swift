//
//  TransactionCellViewModel.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 5/20/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import Foundation

class TransactionCellViewModel {
    var transaction: Transacao
    
    init(transaction: Transacao) {
        self.transaction = transaction
    }
}
