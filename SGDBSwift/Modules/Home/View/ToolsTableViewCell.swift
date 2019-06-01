//
//  ToolsTableViewCell.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 5/19/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import UIKit

class ToolsTableViewCell: UITableViewCell {
    
    //MARK :- Outlets
    @IBOutlet weak var codigo: UILabel!
    @IBOutlet weak var descricao: UILabel!
    @IBOutlet weak var bloqueio: UILabel!
    @IBOutlet weak var contentCell: UIView!
    
    //MARK :- Properties
    public var viewModel: ToolsCellViewModel! {
        didSet {
            configCell()
        }
    }
    
    //MARK :- Functions
    private func configCell() {
        codigo.text = "\(viewModel.tool.id)"
        descricao.text = viewModel.tool.descricao
        
        if viewModel.tool.bloqueio == .compartilhado {
            bloqueio.text = "C"
        } else if viewModel.tool.bloqueio == .exclusivo {
            bloqueio.text = "E"
        } else if viewModel.tool.bloqueio == .desbloqueado {
            bloqueio.text = ""
        }
        
        guard let unSelected = viewModel.isSelected else { return }
        contentCell.backgroundColor = unSelected ? .gray : .darkGray
    }
}
