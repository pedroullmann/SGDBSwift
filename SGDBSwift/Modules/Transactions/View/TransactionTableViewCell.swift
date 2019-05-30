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
        
        switch viewModel.transaction.transacao_estado {
        case .ativa:
            ativoLabel.text = "Ativa"
            ativo.backgroundColor = .lightGray
        case .rollback:
            ativoLabel.text = "Rollback"
            ativo.backgroundColor = UIColor(red: 1.0, green: 0.493, blue: 0.474, alpha: 1.0)
            nome.textColor = UIColor(red: 1.0, green: 0.493, blue: 0.474, alpha: 1.0)
        case .commit:
            ativoLabel.text = "Commit"
            ativo.backgroundColor = UIColor(red: 0.431, green: 0.651, blue: 0.486, alpha: 1.0)
            nome.textColor = UIColor(red: 0.431, green: 0.651, blue: 0.486, alpha: 1.0)
        }
    }
}
