//
//  DeadlockViewController.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 6/16/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import UIKit

protocol DeadlockProtocol: class {
    func tappedRollback(transacao: Int)
}

class DeadlockViewController: UIViewController {
    
    // MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK:- Properties
    private let deadlockWorker: DeadlockWorker = DeadlockWorker()
    private let deadlockCellIdentifier = "deadlockCell"
    private let deadlockCellHeight: CGFloat = 140
    private var transacaoRollback: Int = 0
    private var viewModel: DeadlockViewModel!
    weak var deadlockDelegate: DeadlockProtocol?
    
    //MARK :- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configBind()
        configTableView()
        fetchData()
    }
    
    //MARK :- Functions
    private func configBind() {
        viewModel = DeadlockViewModel(worker: deadlockWorker)
        
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
        
        viewModel.removed.bind { [weak self] removed in
            guard let strongSelf = self, let unDelegate = strongSelf.deadlockDelegate, removed else { return }
            unDelegate.tappedRollback(transacao: strongSelf.transacaoRollback)
        }
    }
    
    private func configTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    private func fetchData() {
        viewModel.fetch()
    }
}

//MARK :- UITableViewDataSource
extension DeadlockViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getElementsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel[indexPath.section][indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: deadlockCellIdentifier, for: indexPath) as? DeadlockTableViewCell  else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        cell.viewModel = cellViewModel
        cell.cellDeadlockDelegate = self
        return cell
    }
}

//MARK :- UITableViewDelegate
extension DeadlockViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return deadlockCellHeight
    }
}

//MARK :- CellDeadLockProtocol
extension DeadlockViewController: CellDeadlockProtocol {
    func tappedRollback(deadlock: Deadlock, transacao: Int) {
        transacaoRollback = transacao
        viewModel.removeDeadlock(deadlock)
    }
}

