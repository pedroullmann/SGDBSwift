//
//  HomeViewController.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 5/19/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import UIKit

protocol HomeProtocol: class {
    func goBackRowModified(ferramenta: Ferramenta, indexRow: Int)
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
    func goBackRowModified(ferramenta: Ferramenta, indexRow: Int) {
        viewModel.toolWasChanged(ferramenta: ferramenta,
                                 indexRow: indexRow)
    }
}

