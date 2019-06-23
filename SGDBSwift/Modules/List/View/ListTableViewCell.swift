//
//  ListTableViewCell.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 6/14/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import UIKit

protocol ListCellProtocol: class {
    func tappedRollback(list: List, transacao: Int)
    func tappedCommit(list: List, transacao: Int)
}

class ListTableViewCell: UITableViewCell {

    // MARK:- Outlets
    @IBOutlet weak var transacaoBloqueada: UILabel!
    @IBOutlet weak var transacaoLiberada: UILabel!
    
    // MARK:- Properties
    weak var listCellDelegate: ListCellProtocol?
    public var viewModel: ListCellViewModel! {
        didSet {
            configCell()
        }
    }

    // MARK:- Functions
    private func configCell() {
        transacaoBloqueada.text = "Transação \(viewModel.list.transacaoBloqueada)"
        transacaoLiberada.text = "Transação \(viewModel.list.transacaoLiberada)"
    }
    
    @IBAction func rollback(_ sender: Any) {
        if let unDelegate = listCellDelegate {
            unDelegate.tappedRollback(list: viewModel.list, transacao: viewModel.list.transacaoLiberada)
        }
    }
    
    @IBAction func commit(_ sender: Any) {
        if let unDelegate = listCellDelegate {
            unDelegate.tappedCommit(list: viewModel.list, transacao: viewModel.list.transacaoLiberada)
        }
    }
}
