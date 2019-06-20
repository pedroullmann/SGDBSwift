//
//  LogViewModel.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 6/20/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import Foundation

class LogViewModel {
    var worker: LogsWorker
    var dataProvider: Dynamic<DataProvider<LogCellViewModel>>
    var error: Dynamic<Error?>
    var elementsCount: Int
    var elementsSection: Int
    
    init(worker: LogsWorker) {
        self.worker = worker
        self.dataProvider = Dynamic(DataProvider())
        self.error = Dynamic(nil)
        self.elementsSection = 0
        self.elementsCount = 0
    }
    
    func mapToLogCellViewModel(_ logs: [Log]) -> [LogCellViewModel] {
        let result = logs.map { log -> LogCellViewModel in
            let cellViewModel = LogCellViewModel(log: log)
            return cellViewModel
        }
        
        return result
    }
}

extension LogViewModel: TableViewViewModelProtocol {
    func fetch() {
        worker.getLogs { [weak self] result in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let logs):
                    let elements = strongSelf.mapToLogCellViewModel(logs)
                    strongSelf.elementsCount = logs.count
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
    
    subscript(section: Int) -> [LogCellViewModel] {
        return dataProvider.value.elements[section]
    }
    
    subscript(section: Int, row: Int) -> LogCellViewModel {
        return dataProvider.value.elements[section][row]
    }
    
    subscript<R>(section: Int, r: R) -> ArraySlice<LogCellViewModel> where R : RangeExpression, Array<LogCellViewModel>.Index == R.Bound {
        return dataProvider.value.elements[section][r]
    }
}
