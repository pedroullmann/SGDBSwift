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
    var transacao: Dynamic<Transacao>
    
    init(worker: DetailWorker, transacao: Transacao) {
        self.dataProvider = Dynamic(DataProvider())
        self.elementsCount = 0
        self.worker = worker
        self.error = Dynamic(nil)
        self.transacao = Dynamic(transacao)
    }
    
    func mapToToolsCellViewModel(_ ferramentas: [Ferramenta]) -> [ToolsCellViewModel] {
        let result = ferramentas.map { tool -> ToolsCellViewModel in
            let toolCellViewModel = ToolsCellViewModel(tool: tool)
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
        let toolCellViewModel = ToolsCellViewModel(tool: tool)
        let indexPath = IndexPath(row: elementsCount - 1, section: 0)
        dataProvider.value.editingStyle = .insert([toolCellViewModel], [indexPath], false)
    }
    
    func reloadToolCell(_ indexPath: IndexPath, ferramenta: Ferramenta, descricao: String) {
        let tool = Ferramenta(id: ferramenta.id, descricao: descricao, bloqueio: .desbloqueado)
        transacao.value.visao[indexPath.row] = tool
        let toolCellViewModel = ToolsCellViewModel(tool: tool)
        dataProvider.value.editingStyle = .reload(toolCellViewModel, indexPath)
    }
    
    func removeToolCell(_ indexPath: IndexPath) {
        elementsCount -= 1
        transacao.value.visao.remove(at: indexPath.row)
        dataProvider.value.editingStyle = .delete([], [indexPath], false)
    }
    
    func reloadToolBloq(_ indexPath: IndexPath, ferramenta: Ferramenta) {
        let tool = Ferramenta(id: ferramenta.id, descricao: ferramenta.descricao, bloqueio: ferramenta.bloqueio)
        let toolCellViewModel = ToolsCellViewModel(tool: tool)
        dataProvider.value.editingStyle = .reload(toolCellViewModel, indexPath)
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
