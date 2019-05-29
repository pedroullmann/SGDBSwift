//
//  DatabaseViewController.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 5/27/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import UIKit

class DatabaseViewController: UIViewController {

    //MARK :- Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK :- Properties
    private let headerCellIdentifier = "headerCell"
    private let cellHeight: CGFloat = 40
    private let toolsCellIdentifier = "toolsCell"
    private let databaseWorker: DatabaseWorker = DatabaseWorker()
    private var viewModel: DatabaseViewModel!
    private var ferramentas: [Ferramenta] = []
    
    //MARK :- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configBind()
        configTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    //MARK :- Functions
    private func configBind() {
        viewModel = DatabaseViewModel(worker: databaseWorker)
        
        viewModel.dataProvider.bind { [weak self] dataProvider in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                switch dataProvider.editingStyle {
                case .reloadAll:
                    strongSelf.tableView.reloadData()
                case .reload(_, let indexPath):
                    strongSelf.tableView.reloadRows(at: [indexPath], with: .automatic)
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
    
    private func configTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    @objc private func fetchData() {
        viewModel.fetch()
    }
}

//MARK :- UITableViewDataSource
extension DatabaseViewController: UITableViewDataSource {
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
extension DatabaseViewController: UITableViewDelegate {
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


