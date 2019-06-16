//
//  DeadlockViewModel.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 6/16/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import Foundation

class DeadlockViewModel {
    var dataProvider: Dynamic<DataProvider<DeadlockCellViewModel>>
    var error: Dynamic<Error?>
    var elementsCount: Int
    var elementsSection: Int
    var worker: DeadlockWorker
    var removed: Dynamic<Bool>
    
    init(worker: DeadlockWorker) {
        self.dataProvider = Dynamic(DataProvider())
        self.elementsCount = 0
        self.elementsSection = 0
        self.worker = worker
        self.error = Dynamic(nil)
        self.removed = Dynamic(false)
    }
    
    func mapToDeadlocksCellViewModel(_ deadlocks: [Deadlock]) -> [DeadlockCellViewModel] {
        let result = deadlocks.map { deadlock -> DeadlockCellViewModel in
            let deadlockCellViewModel = DeadlockCellViewModel(deadlock: deadlock)
            return deadlockCellViewModel
        }

        return result
    }
    
    func removeDeadlock(_ deadlock: Deadlock) {
        worker.removeDeadlock(deadlock: deadlock) { [weak self] result in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    strongSelf.removed.value = true
                case.error:
                    strongSelf.removed.value = false
                }
            }
        }
    }
}

extension DeadlockViewModel: TableViewViewModelProtocol {
    func fetch() {
        worker.getDeadlocks { [weak self] result in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let deadlocks):
                    let elements = strongSelf.mapToDeadlocksCellViewModel(deadlocks)
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
    
    subscript(section: Int) -> [DeadlockCellViewModel] {
        return dataProvider.value.elements[section]
    }
    
    subscript(section: Int, row: Int) -> DeadlockCellViewModel {
        return dataProvider.value.elements[section][row]
    }
    
    subscript<R>(section: Int, r: R) -> ArraySlice<DeadlockCellViewModel> where R : RangeExpression, Array<DeadlockCellViewModel>.Index == R.Bound {
        return dataProvider.value.elements[section][r]
    }
}


