//
//  DetailViewController.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 5/25/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    //MARK :- Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descricao: UITextField!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var remove: UIButton!
    
    //MARK :- Properties
    private let headerCellIdentifier = "headerCell"
    private let toolsCellIdentifier = "toolsCell"
    private let goToDeadlockIdentifier = "toDeadlock"
    private let headerCellHeight: CGFloat = 45
    private let detailWorker: DetailWorker = DetailWorker()
    private var toolIndexPath: IndexPath?
    private var toolModel: Ferramenta?
    private var viewModel: DetailViewModel!
    private var wasDeselected = false
    public var transactionIndexPath: IndexPath?
    public var transacao: Transacao?
    public var transactionsDelegate: TransactionsProtocol?
    
    //MARK :- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configBind()
        configTableView()
        configNavigation()
        fetchData()
        configBlockedBy()
    }
    
    //MARK :- Functions
    private func configBind() {        
        guard let unTransacao = transacao else { return }
        viewModel = DetailViewModel(worker: detailWorker, transacao: unTransacao)
        
        viewModel.dataProvider.bind { [weak self] dataProvider in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch dataProvider.editingStyle {
                case .reloadAll:
                    strongSelf.tableView.reloadData()
                    
                    if let unRow = unTransacao.rowSelected {
                        guard let element = unTransacao.visao[safe: unRow] else { return }
                        let indexPath = IndexPath(row: unRow, section: 0)
                        strongSelf.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                        strongSelf.descricao.text = element.descricao
                        
                        if let cell = strongSelf.tableView.cellForRow(at: indexPath) {
                            cell.contentView.backgroundColor = .gray
                        }
                    }
                case .reload(_, let indexPath):
                    strongSelf.tableView.reloadRows(at: [indexPath], with: .automatic)
                    
                    if let _ = strongSelf.tableView.cellForRow(at: indexPath) {
                        let cellViewModel = strongSelf.viewModel[indexPath.section][indexPath.row]
                        
                        if let unSelected = cellViewModel.isSelected, unSelected {
                            strongSelf.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                        } else {
                            strongSelf.tableView.deselectRow(at: indexPath, animated: false)
                        }
                    }
                    
                case .insert(_, let indexPaths, _):
                    if #available(iOS 11.0, *) {
                        strongSelf.tableView.performBatchUpdates({
                            strongSelf.tableView.insertRows(at: indexPaths, with: .automatic)
                        }, completion: nil)
                    } else {
                        strongSelf.tableView.beginUpdates()
                        strongSelf.tableView.insertRows(at: indexPaths, with: .automatic)
                        strongSelf.tableView.endUpdates()
                    }
                case .delete(_, let indexPaths, _):
                    if #available(iOS 11.0, *) {
                        strongSelf.tableView.performBatchUpdates({
                            strongSelf.tableView.deleteRows(at: indexPaths, with: .automatic)
                        }, completion: nil)
                    } else {
                        strongSelf.tableView.beginUpdates()
                        strongSelf.tableView.deleteRows(at: indexPaths, with: .automatic)
                        strongSelf.tableView.endUpdates()
                    }
                }
            }
        }
        
        viewModel.transacao.bind { [weak self] transacao in
            guard let strongSelf = self else { return }
            strongSelf.transacao = transacao
        }
        
        viewModel.deadlock.bind { [weak self] deadlock in
            guard let strongSelf = self else { return }
            if deadlock {
                strongSelf.performSegue(withIdentifier: strongSelf.goToDeadlockIdentifier, sender: nil)
            }
        }
        
        viewModel.rollbackTransacao.bind { [weak self] rollbackTransacao in
            guard let strongSelf = self,
                let unDelegate = strongSelf.transactionsDelegate,
                let unRollback = rollbackTransacao else { return }
            unDelegate.rollbackTransaction(transacao: unRollback)
        }
        
        viewModel.commitTransacao.bind { [weak self] commitTransacao in
            guard let strongSelf = self,
                let unDelegate = strongSelf.transactionsDelegate,
                let unCommit = commitTransacao else { return }
            unDelegate.commitTransaction(transacao: unCommit)
        }
    }
    
    private func configBlockedBy() {
        guard let unTransacao = transacao, let blockedBy = unTransacao.blockedBy, blockedBy != 0,
            blockedBy != unTransacao.id, let unDelegate = transactionsDelegate else { return }

        let list = List(id: 0, transacaoBloqueada: unTransacao.id, transacaoLiberada: blockedBy)
        unDelegate.createBlockList(list: list)
        
        let alert = UIAlertController(title: "Bloqueio", message: "Este registro está sendo bloqueado pela transação \(blockedBy), vá para a lista de espera para desbloquea-lo.", preferredStyle: .alert)

        let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
            self.navigationController?.popViewController(animated: true)
            self.viewModel.verifyDeadlock()
        })

        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    private func configNavigation() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        if let unTransacao = transacao {
            self.title = unTransacao.nome
        }
    }
    
    private func configTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 44
        tableView.tableFooterView = UIView(frame: .zero)
        container.addShadow()
    }
    
    @objc private func fetchData() {
        viewModel.fetch()
    }
    
    private func cleanComponents() {
        descricao.text = ""
        toolIndexPath = nil
        toolModel = nil
    }
    
    private func modifiedRow(ferramenta: Ferramenta, blockChanged: Bool) {
        if let unDelegate = transactionsDelegate {
            unDelegate.goBackRowModified(ferramenta: ferramenta,
                                         blockChanged: blockChanged)
        }
    }
    
    private func reloadTransaction() {
        guard let unTransactionIndexPath = transactionIndexPath,
            let unDelegate = transactionsDelegate,
            let unTransaction = transacao else { return }
        unDelegate.goBack(unTransactionIndexPath, unTransaction)
    }
    
    //MARK :- Actions
    @IBAction func inserir(_ sender: Any) {
        guard let unDescricao = descricao.text, let unTransacao = transacao else { return }
        let removedSpaces = unDescricao.trimmingCharacters(in: .whitespaces)
        
        if !removedSpaces.isEmpty {
            let log = Log(id: 0, sessao: unTransacao.id, tipo: .inserção, acao: "registro \(unDescricao) foi inserido")
            viewModel.saveLog(log: log)
            viewModel.insertToolCell(unDescricao)
            cleanComponents()
            reloadTransaction()
        }
    }
    
    @IBAction func alterar(_ sender: Any) {
        guard let unIndexPath = toolIndexPath, let unTool = toolModel, let unDescricao = descricao.text, let unTransaction = transacao else { return }
        let removedSpaces = unDescricao.trimmingCharacters(in: .whitespaces)
        
        if !removedSpaces.isEmpty {
            let log = Log(id: 0, sessao: unTransaction.id, tipo: .alteração, acao: "registro \(unTool.descricao) foi alterado para \(unDescricao)")
            viewModel.saveLog(log: log)
            viewModel.reloadToolCell(unIndexPath, ferramenta: unTool, descricao: unDescricao)
            cleanComponents()
            reloadTransaction()
            unTransaction.visao[unIndexPath.row].transacao = unTransaction.id
            modifiedRow(ferramenta: unTransaction.visao[unIndexPath.row], blockChanged: true)
        }
    }
    
    @IBAction func remover(_ sender: Any) {
        guard let unIndexPath = toolIndexPath, toolModel != nil, let unTransaction = transacao else { return }
        
        if let unIndexPath = toolIndexPath, viewModel.verifyChangedTool(indexPath: unIndexPath) {
            let alert = UIAlertController(title: "Atenção", message: "Este registro foi alterado, não será possível remove-lo.", preferredStyle: .alert)
            
            let ok = UIAlertAction(title: "OK", style: .default, handler: { action in
                return
            })
            
            alert.addAction(ok)
            present(alert, animated: true)
            return
        } else {
            if let unDelegate = transactionsDelegate {
                unTransaction.visao[unIndexPath.row].transacao = 0
                unDelegate.goBackRemoveBlock(transacaoId: unTransaction.id, ferramenta: unTransaction.visao[unIndexPath.row])
            }
            
            var auxilary = ""
            if let unTool = toolModel {
                unTransaction.removedId.append(unTool.id)
                auxilary = "registro \(unTool.descricao) foi removido"
            }
            let log = Log(id: 0, sessao: unTransaction.id, tipo: .remoção, acao: auxilary)
            
            viewModel.saveLog(log: log)
            viewModel.removeToolCell(unIndexPath)
            cleanComponents()
            
            unTransaction.rowSelected = nil
            
            reloadTransaction()
        }
    }
    
    @IBAction func commit(_ sender: Any) {
        guard let unTransaction = transacao else { return }
        viewModel.setCommit(removedIds: unTransaction.removedId, transactionId: unTransaction.id)
        
        let log = Log(id: 0, sessao: unTransaction.id, tipo: .commit, acao: "-")
        viewModel.saveLog(log: log)
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func rollback(_ sender: Any) {
        guard let unTransaction = transacao else { return }
        unTransaction.transacao_estado = .rollback
        viewModel.rollbackTransaction(transacaoId: unTransaction.id)
        
        let log = Log(id: 0, sessao: unTransaction.id, tipo: .rollback, acao: "-")
        viewModel.saveLog(log: log)
        _ = navigationController?.popViewController(animated: true)
    }
    
    //MARK :- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == goToDeadlockIdentifier,
            let nav = segue.destination as? UINavigationController,
            let vc = nav.viewControllers.first as? DeadlockViewController {
            vc.deadlockDelegate = self
        }
    }
}

//MARK :- UITableViewDataSource
extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getElementsCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let unTransaction = transacao else { return UITableViewCell() }
        let cellViewModel = viewModel[indexPath.section][indexPath.row]

        guard let cell = tableView.dequeueReusableCell(withIdentifier: toolsCellIdentifier, for: indexPath) as? ToolsTableViewCell  else {
            return UITableViewCell()
        }
        
        if let unRow = unTransaction.rowSelected, unRow == indexPath.row {
            toolIndexPath = indexPath
            toolModel = cellViewModel.tool
        }

        cell.viewModel = cellViewModel

        return cell
    }
}

//MARK :- UITableViewDelegate
extension DetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerCell = tableView.dequeueReusableCell(withIdentifier: headerCellIdentifier) else {
            return UIView()
        }
        return headerCell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerCellHeight
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let unTransaction = transacao else { return }

        if let unRow = unTransaction.rowSelected, unRow == indexPath.row {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            cell.contentView.backgroundColor = .gray
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let unTransaction = transacao,
            let cell = tableView.cellForRow(at: indexPath),
            let unDelegate = transactionsDelegate else { return nil }
        let cellViewModel = viewModel[indexPath.section][indexPath.row]
    
        if cell.isSelected {
            // Deselect Rows
            tableView.deselectRow(at: indexPath, animated: false)
            cell.contentView.backgroundColor = .darkGray
            
            unTransaction.rowSelected = nil
            descricao.text = ""
            
            if let bloq = unTransaction.visao[indexPath.row].bloqueio, bloq == .exclusivo {
                modifiedRow(ferramenta: unTransaction.visao[indexPath.row], blockChanged: true)
            } else {
                unTransaction.visao[indexPath.row].transacao = 0
                unTransaction.visao[indexPath.row].bloqueio = .desbloqueado
                modifiedRow(ferramenta: unTransaction.visao[indexPath.row], blockChanged: false)
            }
        } else {
            
            unTransaction.visao[indexPath.row].transacao = unTransaction.id
            
            if let indexs = tableView.indexPathsForSelectedRows {
                indexs.forEach { index in
                    tableView.deselectRow(at: index, animated: false)
                    if let bloq = unTransaction.visao[index.row].bloqueio, bloq == .exclusivo {
                        unTransaction.visao[indexPath.row].transacao = unTransaction.id
                        return
                    }
                    unTransaction.visao[index.row].transacao = 0
                    unTransaction.visao[index.row].bloqueio = .desbloqueado
                    modifiedRow(ferramenta: unTransaction.visao[index.row], blockChanged: false)
                }
            }
            
            let tool = unTransaction.visao[indexPath.row]
            if let unData = unDelegate.verifyBlock(transacaoId: unTransaction.id, ferramenta: tool) {
                unTransaction.blockedBy = unData
                
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                cell.contentView.backgroundColor = .gray
                
                unTransaction.rowSelected = indexPath.row
                reloadTransaction()
                viewModel.transacao.value = unTransaction
                
                configBlockedBy()
                
                return nil
            }

            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            cell.contentView.backgroundColor = .gray
            
            unTransaction.rowSelected = indexPath.row
            descricao.text = cellViewModel.tool.descricao
            
            if let bloq = tool.bloqueio, bloq != .exclusivo {
                tool.bloqueio = .compartilhado
                modifiedRow(ferramenta: tool, blockChanged: false)
            } else {
                modifiedRow(ferramenta: tool, blockChanged: true)
            }
        }
        
        toolModel = unTransaction.visao[indexPath.row]
        toolIndexPath = indexPath
        reloadTransaction()

        viewModel.transacao.value = unTransaction
        fetchData()
        
        return nil
    }
}

//MARK :- CellDeadLockProtocol
extension DetailViewController: DeadlockProtocol {
    func tappedRollback(transacao: Int) {
        viewModel.rollbackTransaction(transacaoId: transacao)
    }
}
