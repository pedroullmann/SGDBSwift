//
//  DatabaseViewModel.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 5/27/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import Foundation

class DatabaseViewModel {
    var dataProvider: Dynamic<DataProvider<DatabaseCellViewModel>>
    var error: Dynamic<Error?>
    var elementsCount: Int
    var worker: DatabaseWorker
    var ferramentas: Dynamic<[Ferramenta]>
    
    init(worker: DatabaseWorker) {
        self.dataProvider = Dynamic(DataProvider())
        self.elementsCount = 0
        self.worker = worker
        self.error = Dynamic(nil)
        self.ferramentas = Dynamic([])
    }
    
    func mapToToolsCellViewModel(_ ferramentas: [Ferramenta]) -> [DatabaseCellViewModel] {
        let result = ferramentas.map { tool -> DatabaseCellViewModel in
            let toolCellViewModel = DatabaseCellViewModel(ferramenta: tool)
            return toolCellViewModel
        }
        
        return result
    }
}

extension DatabaseViewModel: TableViewViewModelProtocol {
    func fetch() {
        worker.getBancoFisico { [weak self] result in
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
    
    subscript(section: Int) -> [DatabaseCellViewModel] {
        return dataProvider.value.elements[section]
    }
    
    subscript(section: Int, row: Int) -> DatabaseCellViewModel {
        return dataProvider.value.elements[section][row]
    }
    
    subscript<R>(section: Int, r: R) -> ArraySlice<DatabaseCellViewModel> where R : RangeExpression, Array<DatabaseCellViewModel>.Index == R.Bound {
        return dataProvider.value.elements[section][r]
    }
}
