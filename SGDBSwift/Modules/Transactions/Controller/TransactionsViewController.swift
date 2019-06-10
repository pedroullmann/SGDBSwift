//
//  TransactionsViewController.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 5/20/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import UIKit

protocol TransactionsProtocol: class {
    func goBackRowModified(ferramenta: Ferramenta, blockChanged: Bool)
    func goBackRemoveBlock(transacaoId: Int, ferramenta: Ferramenta)
    func goBack(_ indexPath: IndexPath, _ transaction: Transacao)
}

class TransactionsViewController: UIViewController {
    
    //MARK :- Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK :- Properties
    private let transactionsWorker: TransactionsWorker = TransactionsWorker()
    private var viewModel: TransactionsViewModel!
    private var transactionIndexPath: IndexPath?
    private let transactioCellHeight: CGFloat = 130
    private let transactionCellIdentifier = "transactionCell"
    private let detailSegueIdentifier = "goToDetail"
    public var ferramentas: [Ferramenta] = []
    weak var homeDelegate: HomeProtocol?
    
    //MARK :- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configBind()
        configNavigation()
        configTableView()
        fetchData()
    }
    
    //MARK :- Functions
    private func configBind() {
        viewModel = TransactionsViewModel(worker: transactionsWorker, ferramentas: ferramentas)
        
        viewModel.dataProvider.bind { [weak self] dataProvider in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch dataProvider.editingStyle {
                case .reloadAll:
                    strongSelf.tableView.reloadData()
                case .reload(_, let indexPath):
                    strongSelf.tableView.reloadRows(at: [indexPath], with: .automatic)
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
        
        viewModel.buttonEnabled.bind { [weak self] enabled in
            guard let strongSelf = self else { return }
            strongSelf.navigationItem.rightBarButtonItem?.isEnabled = enabled
        }
    }
    
    private func configNavigation() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(criarTransacao))
    }
    
    private func configTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    @objc private func fetchData() {
        viewModel.fetch()
    }
    
    @objc func criarTransacao() {
        viewModel.createTransaction()
    }
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == detailSegueIdentifier,
            let vc = segue.destination as? DetailViewController,
            let transacao = sender as? Transacao {
            vc.transacao = transacao
            
            if let unIndexPath = transactionIndexPath {
                vc.transactionIndexPath = unIndexPath
                vc.transactionsDelegate = self
            }
        }
    }
}

//MARK :- UITableViewDataSource
extension TransactionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getElementsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel[indexPath.section][indexPath.row]

        guard let cell = tableView.dequeueReusableCell(withIdentifier: transactionCellIdentifier, for: indexPath) as? TransactionTableViewCell  else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        cell.viewModel = cellViewModel
        return cell
    }
}

//MARK :- UITableViewDelegate
extension TransactionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return transactioCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellViewModel = viewModel[indexPath.section][indexPath.row]
        let transaction = cellViewModel.transaction
        
        if transaction.transacao_estado == .ativa {
            transactionIndexPath = indexPath
            performSegue(withIdentifier: detailSegueIdentifier, sender: transaction)
        }
    }
}

//MARK :- TransactionsProtocol
extension TransactionsViewController: TransactionsProtocol {
    func goBackRowModified(ferramenta: Ferramenta, blockChanged: Bool) {
        if let unDelegate = homeDelegate {
            unDelegate.goBackRowModified(ferramenta: ferramenta,
                                         blockChanged: blockChanged)
        }
    }
    
    func goBackRemoveBlock(transacaoId: Int, ferramenta: Ferramenta) {
        if let unDelegate = homeDelegate {
            unDelegate.goBackRemoveBlock(transacaoId: transacaoId, ferramenta: ferramenta)
        }
    }
    
    func goBack(_ indexPath: IndexPath, _ transaction: Transacao) {
        let cellViewModel = viewModel[indexPath.section][indexPath.row]
        let transaction = cellViewModel.transaction
        let editedTransaction = transaction

        viewModel.reloadTransactionCell(editedTransaction, indexPath)
    }
}
