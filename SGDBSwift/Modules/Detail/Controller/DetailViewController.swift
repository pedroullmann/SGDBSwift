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
    @IBOutlet weak var codigo: UITextField!
    @IBOutlet weak var descricao: UITextField!
    
    //MARK :- Properties
    private let headerCellIdentifier = "headerCell"
    private let cellHeight: CGFloat = 40
    private let toolsCellIdentifier = "toolsCell"
    private let detailWorker: DetailWorker = DetailWorker()
    private var viewModel: DetailViewModel!
    public var transacao: Transacao?
    
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
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    @objc private func fetchData() {
        viewModel.fetch()
    }
    
    //MARK :- Actions
    @IBAction func inserir(_ sender: Any) {
        
    }
    
    @IBAction func alterar(_ sender: Any) {
        
    }
    
    @IBAction func remover(_ sender: Any) {
        
    }
    
    @IBAction func commit(_ sender: Any) {
        
    }
    
    @IBAction func rollback(_ sender: Any) {
        
    }
}

//MARK :- UITableViewDataSource
extension DetailViewController: UITableViewDataSource {
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
extension DetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerCell = tableView.dequeueReusableCell(withIdentifier: headerCellIdentifier) else {
            return UIView()
        }
        return headerCell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
}

