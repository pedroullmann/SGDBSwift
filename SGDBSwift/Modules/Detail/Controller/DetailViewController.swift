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
    
    //MARK :- Properties
    private let headerCellIdentifier = "headerCell"
    private let toolsCellIdentifier = "toolsCell"
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
        //TODO: Salvar o inserir no log
        guard let unDescricao = descricao.text else { return }
        let removedSpaces = unDescricao.trimmingCharacters(in: .whitespaces)
        
        if !removedSpaces.isEmpty {
            viewModel.insertToolCell(unDescricao)
            cleanComponents()
            reloadTransaction()
        }
    }
    
    @IBAction func alterar(_ sender: Any) {
        //TODO: Salvar o alterar no log
        guard let unIndexPath = toolIndexPath, let unTool = toolModel, let unDescricao = descricao.text, let unTransaction = transacao else { return }
        let removedSpaces = unDescricao.trimmingCharacters(in: .whitespaces)
        
        if !removedSpaces.isEmpty {
            viewModel.reloadToolCell(unIndexPath, ferramenta: unTool, descricao: unDescricao)
            cleanComponents()
            reloadTransaction()
            unTransaction.visao[unIndexPath.row].transacao = unTransaction.id
            modifiedRow(ferramenta: unTransaction.visao[unIndexPath.row], blockChanged: true)
        }
    }
    
    @IBAction func remover(_ sender: Any) {
        //TODO: Salvar o remover no log
        guard let unIndexPath = toolIndexPath, toolModel != nil, let unTransaction = transacao else { return }
        if let unDelegate = transactionsDelegate {
            unDelegate.goBackRemoveBlock(transacaoId: unTransaction.id, ferramenta: unTransaction.visao[unIndexPath.row])
        }
        
        viewModel.removeToolCell(unIndexPath)
        cleanComponents()
        
        unTransaction.rowSelected = nil
        
        reloadTransaction()
    }
    
    @IBAction func commit(_ sender: Any) {
        //TODO: Salvar o commit no log
    }
    
    @IBAction func rollback(_ sender: Any) {
        //TODO: Salvar o rollback no log
        guard let unTransaction = transacao else { return }
        unTransaction.transacao_estado = .rollback
        _ = navigationController?.popViewController(animated: true)
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
        guard let unTransaction = transacao else { return nil }
        guard let cell = tableView.cellForRow(at: indexPath) else { return nil }
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
                unTransaction.visao[indexPath.row].bloqueio = .desbloqueado
                modifiedRow(ferramenta: unTransaction.visao[indexPath.row], blockChanged: false)
            }
        } else {
            // Select Rows
            if let indexs = tableView.indexPathsForSelectedRows {
                indexs.forEach { index in
                    tableView.deselectRow(at: index, animated: false)
                    if let bloq = unTransaction.visao[index.row].bloqueio, bloq == .exclusivo {
                        return
                    }
                    unTransaction.visao[index.row].bloqueio = .desbloqueado
                    modifiedRow(ferramenta: unTransaction.visao[index.row], blockChanged: false)
                }
            }

            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            cell.contentView.backgroundColor = .gray
            
            unTransaction.rowSelected = indexPath.row
            descricao.text = cellViewModel.tool.descricao
            
            unTransaction.visao[indexPath.row].transacao = unTransaction.id
            
            if let bloq = unTransaction.visao[indexPath.row].bloqueio, bloq != .exclusivo {
                unTransaction.visao[indexPath.row].bloqueio = .compartilhado
                modifiedRow(ferramenta: unTransaction.visao[indexPath.row], blockChanged: false)
            } else {
                modifiedRow(ferramenta: unTransaction.visao[indexPath.row], blockChanged: true)
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

