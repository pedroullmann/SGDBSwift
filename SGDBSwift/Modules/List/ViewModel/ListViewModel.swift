//
//  ListViewModel.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 6/14/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import Foundation

class ListViewModel {
    var dataProvider: Dynamic<DataProvider<ListCellViewModel>>
    var error: Dynamic<Error?>
    var elementsCount: Int
    var elementsSection: Int
    var worker: ListWorker
    
    init(worker: ListWorker) {
        self.dataProvider = Dynamic(DataProvider())
        self.elementsCount = 0
        self.elementsSection = 0
        self.worker = worker
        self.error = Dynamic(nil)
    }
}

extension ListViewModel: TableViewViewModelProtocol {
    func fetch() {
//        worker.getTransactions { [weak self] result in
//            guard let strongSelf = self else { return }
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let transactions):
//                    let orderedTransactions = transactions.sorted(by: { $0.id < $1.id })
//                    let elements = strongSelf.mapToTransactionCellViewModel(orderedTransactions)
//                    strongSelf.elementsCount = elements.count
//                    strongSelf.dataProvider.value = DataProvider(withElements: [elements])
//                case .error(let error):
//                    strongSelf.error.value = error
//                }
//            }
//        }
    }
    
    func getElementsCount() -> Int {
        return elementsCount
    }
    
    func getNumbersOfSections() -> Int {
        return dataProvider.value.elements.count
    }
    
    subscript(section: Int) -> [ListCellViewModel] {
        return dataProvider.value.elements[section]
    }
    
    subscript(section: Int, row: Int) -> ListCellViewModel {
        return dataProvider.value.elements[section][row]
    }
    
    subscript<R>(section: Int, r: R) -> ArraySlice<ListCellViewModel> where R : RangeExpression, Array<ListCellViewModel>.Index == R.Bound {
        return dataProvider.value.elements[section][r]
    }
}

