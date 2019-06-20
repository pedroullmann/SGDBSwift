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
    var elementsSection: Int
    var worker: TransactionsWorker
    var rollbackTransaction: Dynamic<Transacao?>
    var reloadTransactions: Dynamic<Bool>
    var workerDetail: DetailWorker
    var buttonEnabled: Dynamic<Bool>
    var logWorker: LogsWorker
    var listWorker: ListWorker
    
    init(worker: TransactionsWorker, ferramentas: [Ferramenta]) {
        self.dataProvider = Dynamic(DataProvider())
        self.elementsCount = 0
        self.elementsSection = 0
        self.worker = worker
        self.ferramentas = ferramentas
        self.buttonEnabled = Dynamic(true)
        self.reloadTransactions = Dynamic(false)
        self.rollbackTransaction = Dynamic(nil)
        self.workerDetail = DetailWorker()
        self.error = Dynamic(nil)
        self.logWorker = LogsWorker()
        self.listWorker = ListWorker()
    }
    
    func mapToTransactionCellViewModel(_ transactions: [Transacao]) -> [TransactionCellViewModel] {
        let result = transactions.map { transaction -> TransactionCellViewModel in
            let transactionCellViewModel = TransactionCellViewModel(transaction: transaction)
            return transactionCellViewModel
        }
        
        return result
    }
    
    func reloadTransactionCell(_ transaction: Transacao, _ indexPath: IndexPath) {
        worker.modifyTransaction(trasaction: transaction) { [weak self] result in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    let transcatioNCellViewModel = TransactionCellViewModel(transaction: transaction)
                    strongSelf.dataProvider.value.editingStyle = .reload(transcatioNCellViewModel, indexPath)
                case .error:
                    break
                }
            }
        }
    }
    
    func rollbackTransaction(_ transaction: Transacao) {
        guard let unIndex = getIndexOfViewModel(by: transaction) else { return }
        let indexPath = IndexPath(row: unIndex, section: elementsSection)
        let transactionCell = TransactionCellViewModel(transaction: transaction)
        dataProvider.value.editingStyle = .reload(transactionCell, indexPath)
        rollbackTransaction.value = transaction
        reloadTransactions.value = true
    }
    
    func getIndexOfViewModel(by transacao: Transacao) -> Array<TransactionCellViewModel>.Index? {
        guard elementsSection < dataProvider.value.elements.count else { return nil }
        let indexRow = dataProvider.value.elements[elementsSection].firstIndex { (viewModel) -> Bool in
            if viewModel.transaction.id == transacao.id, viewModel.transaction.data == transacao.data {
                return true
            }
            return false
        }
        return indexRow
    }
    
    func createBlock(list: List) {
        listWorker.createBlock(list: list) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("SUCESSO")
                case .error:
                    break
                }
            }
        }
    }
    
    func rollbackTransaction(transacaoId: Int) {
        workerDetail.rollbackTransaction(transacaoId: transacaoId) { [weak self] result in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let transacao):
                    strongSelf.rollbackTransaction(transacao)
                    strongSelf.reloadTransactions.value = true
                case .error:
                    break
                }
            }
        }
    }
    
    func saveLog(log: Log) {
        logWorker.createLog(log: log) { result in
            switch result { default: break }
        }
    }
}

extension TransactionsViewModel: TableViewViewModelProtocol {
    func fetch() {
        worker.getTransactions { [weak self] result in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
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
        worker.createTransaction { [weak self] result in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let transaction):
                    let indexPath = IndexPath(row: strongSelf.elementsCount - 1, section: 0)
                    let elements = strongSelf.mapToTransactionCellViewModel([transaction])
                    strongSelf.dataProvider.value.editingStyle = .insert([elements.last!], [indexPath], false)
                    
                    let log = Log(id: 0, sessao: transaction.id, tipo: .instanciada, acao: "acabou de ser instanciada")
                    strongSelf.saveLog(log: log)
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
