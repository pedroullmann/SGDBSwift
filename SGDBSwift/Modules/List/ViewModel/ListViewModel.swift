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
    var logWorker: LogsWorker
    var commitWorker: CommitWorker
    
    init(worker: ListWorker) {
        self.dataProvider = Dynamic(DataProvider())
        self.elementsCount = 0
        self.elementsSection = 0
        self.worker = worker
        self.logWorker = LogsWorker()
        self.commitWorker = CommitWorker()
        self.error = Dynamic(nil)
    }
    
    func mapToListCellViewModel(_ list: [List]) -> [ListCellViewModel] {
        let result = list.map { block -> ListCellViewModel in
            let listCellViewModel = ListCellViewModel(list: block)
            return listCellViewModel
        }
        
        return result
    }
    
    func rollbackTransaction(transacao: Int) {
        guard let unIndex = getIndexOfViewModel(by: transacao) else { return }
        let indexPath = IndexPath(row: unIndex, section: elementsSection)
        
        if let element = dataProvider.value.elements[elementsSection][safe: unIndex]?.list {
            worker.removeBlock(bloqueadaId: element.transacaoBloqueada, liberada: transacao) { [weak self] result in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        strongSelf.elementsCount -= 1
                        strongSelf.dataProvider.value.editingStyle = .delete([], [indexPath], false)
                    case .error:
                        break
                    }
                }
            }
        }
    }
    
    func getIndexOfViewModel(by transacao: Int) -> Array<ListCellViewModel>.Index? {
        guard elementsSection < dataProvider.value.elements.count else { return nil }
        let indexRow = dataProvider.value.elements[elementsSection].firstIndex { (viewModel) -> Bool in
            if viewModel.list.transacaoLiberada == transacao {
                return true
            }
            return false
        }
        return indexRow
    }
    
    func saveLog(log: Log) {
        logWorker.createLog(log: log) { result in
            switch result { default: break }
        }
    }
}

extension ListViewModel: TableViewViewModelProtocol {
    func fetch() {
        worker.getListBlock { [weak self] result in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    let elements = strongSelf.mapToListCellViewModel(list)
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

