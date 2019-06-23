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
    var elementsSection: Int
    var transacao: Dynamic<Transacao>
    var rollbackTransacao: Dynamic<Transacao?>
    var deadlockWorker: DeadlockWorker
    var logWorker: LogsWorker
    var commitWorker: CommitWorker
    var commitTransacao: Dynamic<Transacao?>
    var deadlock: Dynamic<Bool>
    
    init(worker: DetailWorker, transacao: Transacao) {
        self.dataProvider = Dynamic(DataProvider())
        self.elementsCount = 0
        self.elementsSection = 0
        self.worker = worker
        self.error = Dynamic(nil)
        self.rollbackTransacao = Dynamic(nil)
        self.transacao = Dynamic(transacao)
        self.deadlockWorker = DeadlockWorker()
        self.logWorker = LogsWorker()
        self.commitWorker = CommitWorker()
        self.commitTransacao = Dynamic(nil)
        self.deadlock = Dynamic(false)
    }
    
    func mapToToolsCellViewModel(_ ferramentas: [Ferramenta]) -> [ToolsCellViewModel] {
        let result = ferramentas.map { tool -> ToolsCellViewModel in
            let toolCellViewModel = ToolsCellViewModel(tool: tool, isTransaction: true)
            return toolCellViewModel
        }
        
        return result
    }
    
    func insertToolCell(_ descricao: String) {
        var toolId: Int = 1
        if let inIndexRange = dataProvider.value.elements[safe: 0], let lastElement = inIndexRange.last {
            toolId = lastElement.tool.id + 1
        }
        elementsCount += 1
        let tool = Ferramenta(id: toolId, descricao: descricao, bloqueio: .desbloqueado)
        transacao.value.visao.append(tool)
        let toolCellViewModel = ToolsCellViewModel(tool: tool, isTransaction: true)
        let indexPath = IndexPath(row: elementsCount - 1, section: 0)
        dataProvider.value.editingStyle = .insert([toolCellViewModel], [indexPath], false)
    }
    
    func reloadToolCell(_ indexPath: IndexPath, ferramenta: Ferramenta, descricao: String) {
        let tool = Ferramenta(id: ferramenta.id, descricao: descricao, bloqueio: .exclusivo)
        transacao.value.visao[indexPath.row] = tool
        let toolCellViewModel = ToolsCellViewModel(tool: tool, isTransaction: true)
        dataProvider.value.editingStyle = .reload(toolCellViewModel, indexPath)
    }
    
    func removeToolCell(_ indexPath: IndexPath) {
        elementsCount -= 1
        transacao.value.visao.remove(at: indexPath.row)
        dataProvider.value.editingStyle = .delete([], [indexPath], false)
    }
    
    func verifyChangedTool(indexPath: IndexPath) -> Bool {
        if let element = dataProvider.value.elements[elementsSection][safe: indexPath.row],
            let unBlock = element.tool.bloqueio {
            return unBlock == .exclusivo
        }
        
        return false
    }
    
    func verifyDeadlock() {
        deadlockWorker.verifyDeadlock { [weak self] result in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    strongSelf.deadlock.value = true
                case .error:
                    strongSelf.deadlock.value = false
                }
            }
        }
    }
    
    func rollbackTransaction(transacaoId: Int) {
        worker.rollbackTransaction(transacaoId: transacaoId) { [weak self] result in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let transacao):
                    strongSelf.rollbackTransacao.value = transacao
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
    
    func setCommit(removedIds: [Int], transactionId: Int) {
        commitWorker.setCommit(removedIds: removedIds, transactionId: transactionId) { [weak self] result in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let transaction):
                    strongSelf.commitTransacao.value = transaction
                case .error(let error):
                    strongSelf.error.value = error
                }
            }
        }
    }
}

extension DetailViewModel: TableViewViewModelProtocol {
    func fetch() {
        let elements = mapToToolsCellViewModel(transacao.value.visao)
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
