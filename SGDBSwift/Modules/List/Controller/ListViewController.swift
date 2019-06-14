//
//  ListViewController.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 6/14/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    
    // MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK:- Properties
    private let listWorker: ListWorker = ListWorker()
    private let listCellIdentifier = "listCell"
    private let deadlockCellIdentifier = "deadlockCell"
    private let listCellHeight: CGFloat = 115
    private let deadlockCellHeight: CGFloat = 160
    private var viewModel: ListViewModel!
    
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
        viewModel = ListViewModel(worker: listWorker)
        
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
        let exit = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(exitAction))
        navigationItem.leftBarButtonItem = exit
    }
    
    private func configTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    private func fetchData() {
        viewModel.fetch()
    }
    
    @objc func exitAction() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK :- UITableViewDataSource
extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getElementsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel[indexPath.section][indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: listCellIdentifier, for: indexPath) as? ListTableViewCell  else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        cell.viewModel = cellViewModel
        return cell
    }
}

//MARK :- UITableViewDelegate
extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return listCellHeight
    }
}
