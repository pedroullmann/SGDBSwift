//
//  LogTableViewCell.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 6/20/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import UIKit

class LogTableViewCell: UITableViewCell {
    
    // MARK:- Outlets
    @IBOutlet weak var sessao: UILabel!
    @IBOutlet weak var tipo: UILabel!
    @IBOutlet weak var acao: UILabel!
    
    // MARK:- Properties
    public var viewModel: LogCellViewModel! {
        didSet {
            configCell()
        }
    }
    
    // MARK:- Functions
    private func configCell() {
        sessao.text = "Transação \(viewModel.log.sessao)"
        
        switch viewModel.log.tipo {
        case .alteração:
            tipo.text = "Alteração"
        case .checkpoint:
            tipo.text = "Checkpoint"
        case .commit:
            tipo.text = "Commit"
        case .inserção:
            tipo.text = "Inserção"
        case .instanciada:
            tipo.text = "Instanciada"
        case .remoção:
            tipo.text = "Remoção"
        case .rollback:
            tipo.text = "Rollback"
        }
        
        acao.text = viewModel.log.acao
    }
}
