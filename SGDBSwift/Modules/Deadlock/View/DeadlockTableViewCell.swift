//
//  DeadlockTableViewCell.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 6/16/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import UIKit

protocol CellDeadlockProtocol: class {
    func tappedRollback(deadlock: Deadlock, transacao: Int)
}

class DeadlockTableViewCell: UITableViewCell {
    // MARK:- Outlets
    @IBOutlet weak var primeira_transacaoBloqueada: UILabel!
    @IBOutlet weak var segunda_transacaoBloqueada: UILabel!
    
    // MARK:- Properties
    weak var cellDeadlockDelegate: CellDeadlockProtocol?
    public var viewModel: DeadlockCellViewModel! {
        didSet {
            configCell()
        }
    }
    
    // MARK:- Functions
    private func configCell() {
        primeira_transacaoBloqueada.text = "Transação \(viewModel.deadlock.primeira_transacaoBloqueada)"
        segunda_transacaoBloqueada.text = "Transação \(viewModel.deadlock.segunda_transacaoBloqueada)"
    }
    
    @IBAction func rollbackPrimeira(_ sender: Any) {
        if let unDelegate = cellDeadlockDelegate {
            unDelegate.tappedRollback(deadlock: viewModel.deadlock,
                                      transacao: viewModel.deadlock.primeira_transacaoBloqueada)
        }
    }
    
    @IBAction func rollbackSegunda(_ sender: Any) {
        if let unDelegate = cellDeadlockDelegate {
            unDelegate.tappedRollback(deadlock: viewModel.deadlock,
                                      transacao: viewModel.deadlock.segunda_transacaoBloqueada)
        }
    }
}
