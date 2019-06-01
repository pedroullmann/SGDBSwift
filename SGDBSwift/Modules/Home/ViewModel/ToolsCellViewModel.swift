//
//  ToolsCellViewModel.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 5/19/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import Foundation

class ToolsCellViewModel {
    var tool: Ferramenta
    var isSelected: Bool?
    
    init(tool: Ferramenta, isSelected: Bool? = false) {
        self.tool = tool
        self.isSelected = isSelected
    }
}
