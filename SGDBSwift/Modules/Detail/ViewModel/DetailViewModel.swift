//
//  DetailViewModel.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 5/27/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import Foundation

class DetailViewModel {
    var dataProvider: Dynamic<DataProvider<ToolsCellViewModel>>
    var error: Dynamic<Error?>
    var elementsCount: Int
    var worker: DetailWorker
    var transacao: Transacao
    
    init(worker: DetailWorker, transacao: Transacao) {
        self.dataProvider = Dynamic(DataProvider())
        self.elementsCount = 0
        self.worker = worker
        self.error = Dynamic(nil)
        self.transacao = transacao
    }
    
    func mapToToolsCellViewModel(_ ferramentas: [Ferramenta]) -> [ToolsCellViewModel] {
        let result = ferramentas.map { tool -> ToolsCellViewModel in
            let toolCellViewModel = ToolsCellViewModel(tool: tool)
            return toolCellViewModel
        }
        
        return result
    }
}

extension DetailViewModel: TableViewViewModelProtocol {
    func fetch() {
        let elements = mapToToolsCellViewModel(transacao.visao)
        elementsCount = elements.count
        dataProvider.value = DataProvider(withElements: [elements])
    }
    
    func getElementsCount() -> Int {
        return elementsCount
    }
    
    func getNumbersOfSections() -> Int {
        return dataProvider.value.elements.count
    }
    
    subscript(section: Int) -> [ToolsCellViewModel] {
        return dataProvider.value.elements[section]
    }
    
    subscript(section: Int, row: Int) -> ToolsCellViewModel {
        return dataProvider.value.elements[section][row]
    }
    
    subscript<R>(section: Int, r: R) -> ArraySlice<ToolsCellViewModel> where R : RangeExpression, Array<ToolsCellViewModel>.Index == R.Bound {
        return dataProvider.value.elements[section][r]
    }
}
