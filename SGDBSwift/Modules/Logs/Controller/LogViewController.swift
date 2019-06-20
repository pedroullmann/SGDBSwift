//
//  LogViewController.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 6/20/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import UIKit

class LogViewController: UIViewController {
    
    // MARK:- Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK:- Properties
    private let headerCellIdentifier = "headerCell"
    private let headerCellHeight: CGFloat = 45
    private let logCellIdentifier = "logCell"
    private let logWorker: LogsWorker = LogsWorker()
    private var viewModel: LogViewModel!
    
    // MARK:- Lifecycle
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
        viewModel = LogViewModel(worker: logWorker)
        
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
}

//MARK :- UITableViewDataSource
extension LogViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getElementsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = viewModel[indexPath.section][indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: logCellIdentifier, for: indexPath) as? LogTableViewCell  else {
            return UITableViewCell()
        }
        
        cell.viewModel = cellViewModel
        return cell
    }
}

//MARK :- UITableViewDelegate
extension LogViewController: UITableViewDelegate {
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
