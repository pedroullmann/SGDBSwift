//
//  DatabaseTableViewCell.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 6/26/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import UIKit

class DatabaseTableViewCell: UITableViewCell {
    
    // MARK:- Outlets
    @IBOutlet weak var codigo: UILabel!
    @IBOutlet weak var descricao: UILabel!
    
    //MARK :- Properties
    public var viewModel: DatabaseCellViewModel! {
        didSet {
            configCell()
        }
    }
    
    //MARK :- Functions
    private func configCell() {
        codigo.text = "\(viewModel.ferramenta.id)"
        descricao.text = viewModel.ferramenta.descricao
    }
}
