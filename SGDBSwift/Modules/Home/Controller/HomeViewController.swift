//
//  HomeViewController.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 5/19/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import UIKit

protocol HomeProtocol: class {
    func goBackRowModified(ferramenta: Ferramenta, blockChanged: Bool)
    func verifyBlock(transacaoId: Int, ferramenta: Ferramenta) -> Int?
    func goBackRemoveBlock(transacaoId: Int, ferramenta: Ferramenta)
    func reloadTemporary()
    func rollbackTransaction(transactionId: Int)
}

class HomeViewController: UIViewController {
    
    //MARK :- Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK :- Properties
    private let headerCellIdentifier = "headerCell"
    private let headerCellHeight: CGFloat = 45
    private let goToTransacoesIdentifier = "goToTransacoes"
    private let toolsCellIdentifier = "toolsCell"
    private let homeWorker: HomeWorker = HomeWorker()
    private var viewModel: HomeViewModel!
    private var ferramentas: [Ferramenta] = []
    
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
        viewModel = HomeViewModel(worker: homeWorker)
        
        viewModel.dataProvider.bind { [weak self] dataProvider in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch dataProvider.editingStyle {
                case .reloadAll:
                    strongSelf.tableView.reloadData()
                case .reload(_, let indexPath):
                    strongSelf.tableView.reloadRows(at: [indexPath], with: .automatic)
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
                default:
                    break
                }
            }
        }
        
        viewModel.ferramentas.bind { [weak self] ferramentas in
            guard let strongSelf = self else { return }
            strongSelf.ferramentas = ferramentas
        }
    }
    
    private func configNavigation() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    private func configTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 44
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    @objc private func fetchData() {
        viewModel.fetch()
    }
    
    @IBAction func goToTransacoes(_ sender: Any) {
        performSegue(withIdentifier: goToTransacoesIdentifier, sender: ferramentas)
    }
    
    @IBAction func checkPoint(_ sender: Any) {
        let alert = UIAlertController(title: "Checkpoint", message: "Você confirma a execução deste checkpoint?", preferredStyle: .alert)
        
        let confirmar = UIAlertAction(title: "Confirmo", style: .default, handler: { action in
            let log = Log(id: 0, sessao: 0, tipo: .checkpoint, acao: "-")
            self.viewModel.checkpoint(log: log)
        })
        
        alert.addAction(confirmar)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    // MARK :- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == goToTransacoesIdentifier,
            let vc = segue.destination as? TransactionsViewController,
            let ferramentas = sender as? [Ferramenta] {
            vc.ferramentas = ferramentas
            vc.homeDelegate = self
        }
    }
}

//MARK :- UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getElementsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel[indexPath.section][indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: toolsCellIdentifier, for: indexPath) as? ToolsTableViewCell  else {
            return UITableViewCell()
        }
        
        cell.viewModel = cellViewModel
        return cell
    }
}

//MARK :- UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
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
}

extension HomeViewController: HomeProtocol {
    func goBackRowModified(ferramenta: Ferramenta, blockChanged: Bool) {
        viewModel.toolWasChanged(ferramenta: ferramenta,
                                 blockChanged: blockChanged)
    }
    
    func verifyBlock(transacaoId: Int, ferramenta: Ferramenta) -> Int? {
        return viewModel.verifyBlock(transacaoId: transacaoId, ferramenta: ferramenta)
    }
    
    func reloadTemporary() {
        viewModel.fetch()
    }
    
    func rollbackTransaction(transactionId: Int) {
        viewModel.rollbackTransaction(transacaoId: transactionId)
    }
    
    func goBackRemoveBlock(transacaoId: Int, ferramenta: Ferramenta) {
        viewModel.removeBlock(transacaoId: transacaoId, ferramenta: ferramenta)
    }
}

