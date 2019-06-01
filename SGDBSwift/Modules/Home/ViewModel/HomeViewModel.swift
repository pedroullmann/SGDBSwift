//
//  HomeViewModel.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 5/19/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import Foundation

class HomeViewModel {
    var dataProvider: Dynamic<DataProvider<ToolsCellViewModel>>
    var error: Dynamic<Error?>
    var elementsCount: Int
    var worker: HomeWorker
    var elementsSection: Int
    var ferramentas: Dynamic<[Ferramenta]>
    
    init(worker: HomeWorker) {
        self.dataProvider = Dynamic(DataProvider())
        self.elementsCount = 0
        self.worker = worker
        self.error = Dynamic(nil)
        self.ferramentas = Dynamic([])
        self.elementsSection = 0
    }
    
    func mapToToolsCellViewModel(_ ferramentas: [Ferramenta]) -> [ToolsCellViewModel] {
        let result = ferramentas.map { tool -> ToolsCellViewModel in
            let toolCellViewModel = ToolsCellViewModel(tool: tool)
            return toolCellViewModel
        }
        
        return result
    }
    
    func toolWasChanged(ferramenta: Ferramenta, indexRow: Int) {
        if dataProvider.value.elements[elementsSection].firstIndex(where: { element -> Bool in
            return element.tool == ferramenta
        }) != nil {
            let indexPath = IndexPath(row: indexRow, section: elementsSection)
            let cell = ToolsCellViewModel(tool: ferramenta)
            dataProvider.value.editingStyle = .reload(cell, indexPath)
        }
    }
}

extension HomeViewModel: TableViewViewModelProtocol {
    func fetch() {
        worker.getBancoTemporario { [weak self] result in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                switch result {
                case .success(let ferramentas):
                    let elements = strongSelf.mapToToolsCellViewModel(ferramentas)
                    strongSelf.ferramentas.value = ferramentas
                    strongSelf.elementsCount = elements.count
                    strongSelf.dataProvider.value = DataProvider(withElements: [elements])
                case .error(let error):
                    strongSelf.error.value = error
                }
            }
        }
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
