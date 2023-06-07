//
//  MemoListViewController.swift
//  MemoProject
//
//  Created by Kant on 2023/06/03.
//

import UIKit
import RxSwift
import RxCocoa

class MemoListViewController: UIViewController {
    
    private let viewModel: MemoListViewModel
    private let disposeBag = DisposeBag()

    private var tableView: UITableView!

    init(viewModel: MemoListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupViews()
        bindViewModel()
    }

    private func setupTableView() {
        tableView = UITableView()
        tableView.register(MemoCell.self, forCellReuseIdentifier: "MemoCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.memos
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] _ in
                    self?.tableView.reloadData()
                })
                .disposed(by: disposeBag)
        
        viewModel.memos
            .bind(to: tableView.rx.items(cellIdentifier: "MemoCell", cellType: MemoCell.self)) { row, memo, cell in
                cell.configure(with: memo)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                let filteredMemos = self.viewModel.memos.value.filter { $0 != self.viewModel.memos.value[indexPath.row] }
                self.viewModel.memos.accept(filteredMemos)
            })
            .disposed(by: disposeBag)

    }
    
    private func setupViews() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }

    @objc private func addButtonTapped() {
        showCreateMemoAlert()
    }

    private func showCreateMemoAlert() {
        let alertController = UIAlertController(title: "Create Memo", message: nil, preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Title"
        }

        alertController.addTextField { textField in
            textField.placeholder = "Content"
        }

        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let title = alertController.textFields?.first?.text,
                  let content = alertController.textFields?.last?.text else {
                return
            }
            
            self?.viewModel.createMemo(title: title, content: content)
                .subscribe(onNext: { [weak self] _ in
                    self?.viewModel.loadMemos()
                })
                .disposed(by: self?.disposeBag ?? DisposeBag())
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(createAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

}


