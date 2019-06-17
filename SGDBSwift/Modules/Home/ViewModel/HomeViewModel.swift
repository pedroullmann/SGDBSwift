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
            let toolCellViewModel = ToolsCellViewModel(tool: tool, isTransaction: false)
            return toolCellViewModel
        }
        
        return result
    }
    
    func toolWasChanged(ferramenta: Ferramenta, blockChanged: Bool) {
        guard let index = getIndexOfViewModel(by: ferramenta, blockChanged: blockChanged) else { return }
        let indexPath = IndexPath(row: index, section: elementsSection)
        
        if blockChanged {
            if let element = dataProvider.value.elements[elementsSection][safe: index]?.tool {
                element.transacao = ferramenta.transacao
                element.bloqueio = ferramenta.bloqueio
                let cell = ToolsCellViewModel(tool: element, isTransaction: false)
                dataProvider.value.editingStyle = .reload(cell, indexPath)
            }
        } else {
            let cell = ToolsCellViewModel(tool: ferramenta, isTransaction: false)
            dataProvider.value.editingStyle = .reload(cell, indexPath)
        }
    }
    
    func verifyBlock(transacaoId: Int, ferramenta: Ferramenta) -> Int? {
        guard let index = getIndexOfViewModel(by: ferramenta, blockChanged: true) else { return nil }
        
        if let unElement = dataProvider.value.elements[elementsSection][safe: index]?.tool,
            let unBlock = unElement.bloqueio, unBlock == .exclusivo,
            let unTransacao = unElement.transacao, unTransacao != 0, unTransacao != transacaoId {
            return unTransacao
        }
        
        return nil
    }
    
    func getIndexOfViewModel(by tool: Ferramenta, blockChanged: Bool) -> Array<ToolsCellViewModel>.Index? {
        guard elementsSection < dataProvider.value.elements.count else { return nil }
        let indexRow = dataProvider.value.elements[elementsSection].firstIndex { (viewModel) -> Bool in
            if blockChanged, viewModel.tool.id == tool.id {
                return true
            } else if viewModel.tool.id == tool.id, viewModel.tool.descricao == tool.descricao {
                return true
            }
            return false
        }
        return indexRow
    }
    
    func removeBlock(transacaoId: Int, ferramenta: Ferramenta) {
        guard let index = getIndexOfViewModel(by: ferramenta, blockChanged: true) else { return }
        let indexPath = IndexPath(row: index, section: elementsSection)
        
        if let element = dataProvider.value.elements[elementsSection][safe: index]?.tool,
            let id = element.transacao, id == transacaoId {
            element.bloqueio = .desbloqueado
            element.transacao = 0

            let cell = ToolsCellViewModel(tool: element, isTransaction: false)
            dataProvider.value.editingStyle = .reload(cell, indexPath)
        }
    }
    
    func rollbackTransaction(transacaoId: Int) {
        dataProvider.value.elements[elementsSection].forEach { tool in
            if let unTransacao = tool.tool.transacao, unTransacao == transacaoId {
                tool.tool.bloqueio = .desbloqueado
                tool.tool.transacao = 0
            }
        }
        
        dataProvider.value.editingStyle = .reloadAll
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
