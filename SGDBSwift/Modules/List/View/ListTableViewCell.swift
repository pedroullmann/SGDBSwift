//
//  ListTableViewCell.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 6/14/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {

    // MARK:- Outlets
    @IBOutlet weak var transacaoBloqueada: UILabel!
    @IBOutlet weak var transacaoLiberada: UILabel!
    
    // MARK:- Properties
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
        //TODO: Logs
    }
    
    @IBAction func commit(_ sender: Any) {
        //TODO: Logs
    }
}
