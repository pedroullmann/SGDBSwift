//
//  TransactionsViewModel.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 5/20/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import Foundation

class TransactionsViewModel {
    var dataProvider: Dynamic<DataProvider<TransactionCellViewModel>>
    var error: Dynamic<Error?>
    var elementsCount: Int
    var ferramentas: [Ferramenta]
    var worker: TransactionsWorker
    var buttonEnabled: Dynamic<Bool>
    
    init(worker: TransactionsWorker, ferramentas: [Ferramenta]) {
        self.dataProvider = Dynamic(DataProvider())
        self.elementsCount = 0
        self.worker = worker
        self.ferramentas = ferramentas
        self.buttonEnabled = Dynamic(true)
        self.error = Dynamic(nil)
    }
    
    func mapToTransactionCellViewModel(_ transactions: [Transacao]) -> [TransactionCellViewModel] {
        let result = transactions.map { transaction -> TransactionCellViewModel in
            let transactionCellViewModel = TransactionCellViewModel(transaction: transaction)
            return transactionCellViewModel
        }
        
        return result
    }
    
    func reloadTransactionCell(_ transaction: Transacao, _ indexPath: IndexPath) {
        let transcatioNCellViewModel = TransactionCellViewModel(transaction: transaction)
        dataProvider.value.editingStyle = .reload(transcatioNCellViewModel, indexPath)
    }
}

extension TransactionsViewModel: TableViewViewModelProtocol {
    func fetch() {
        worker.getTransactions { [weak self] result in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                switch result {
                case .success(let transactions):
                    let orderedTransactions = transactions.sorted(by: { $0.id < $1.id })
                    let elements = strongSelf.mapToTransactionCellViewModel(orderedTransactions)
                    strongSelf.elementsCount = elements.count
                    strongSelf.dataProvider.value = DataProvider(withElements: [elements])
                case .error(let error):
                    strongSelf.error.value = error
                }
            }
        }
    }
    
    func createTransaction() {
        elementsCount += 1
        buttonEnabled.value = false
        worker.createTransaction(ferramentas: ferramentas) { [weak self] result in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                switch result {
                case .success(let transaction):
                    let indexPath = IndexPath(row: strongSelf.elementsCount - 1, section: 0)
                    let elements = strongSelf.mapToTransactionCellViewModel([transaction])
                    strongSelf.dataProvider.value.editingStyle = .insert([elements.last!], [indexPath], false)
                case .error(let error):
                    strongSelf.elementsCount -= 1
                    strongSelf.error.value = error
                }
                strongSelf.buttonEnabled.value = true
            }
        }
    }
    
    func getElementsCount() -> Int {
        return elementsCount
    }
    
    func getNumbersOfSections() -> Int {
        return dataProvider.value.elements.count
    }
    
    subscript(section: Int) -> [TransactionCellViewModel] {
        return dataProvider.value.elements[section]
    }
    
    subscript(section: Int, row: Int) -> TransactionCellViewModel {
        return dataProvider.value.elements[section][row]
    }
    
    subscript<R>(section: Int, r: R) -> ArraySlice<TransactionCellViewModel> where R : RangeExpression, Array<TransactionCellViewModel>.Index == R.Bound {
        return dataProvider.value.elements[section][r]
    }
}
