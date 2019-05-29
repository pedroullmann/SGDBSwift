//
//  TransactionTableViewCell.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 5/21/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    
    //MARK :- Outlets
    @IBOutlet weak var nome: UILabel!
    @IBOutlet weak var ativo: UIView!
    @IBOutlet weak var ativoLabel: UILabel!
    
    //MARK :- Properties
    public var viewModel: TransactionCellViewModel! {
        didSet {
            configCell()
        }
    }
    
    //MARK :- Functions
    private func configCell() {
        nome.text = viewModel.transaction.nome
//        ativo.backgroundColor = viewModel.transaction.transacao_ativa ? UIColor.green : UIColor.red
//        ativoLabel.text = viewModel.transaction.transacao_ativa ? "Ativa" : "Inativa"
    }
}
