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
    @IBOutlet weak var dataCriacao: UILabel!
    
    //MARK :- Properties
    public var viewModel: TransactionCellViewModel! {
        didSet {
            configCell()
        }
    }
    
    //MARK :- Functions
    private func configCell() {
        nome.text = viewModel.transaction.nome
        dataCriacao.text = viewModel.transaction.data
        ativo.addShadow()
        
        switch viewModel.transaction.transacao_estado {
        case .ativa:
            ativo.backgroundColor = .lightGray
        case .rollback:
            ativo.backgroundColor = UIColor(red: 1.0, green: 0.493, blue: 0.474, alpha: 1.0)
            self.accessoryType = .none
        case .commit:
            ativo.backgroundColor = UIColor(red: 0.431, green: 0.651, blue: 0.486, alpha: 1.0)
            self.accessoryType = .none
        }
    }
}
