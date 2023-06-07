//
//  MemoDetailViewController.swift
//  MemoProject
//
//  Created by Kant on 2023/06/03.
//

import UIKit
import RxSwift

class MemoDetailViewController: UIViewController {
    
    private let viewModel: MemoDetailViewModel
    private let disposeBag = DisposeBag()

    private var titleTextField: UITextField!
    private var contentTextView: UITextView!

    init(viewModel: MemoDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        bindViewModel()
    }

    private func setupViews() {
        titleTextField = UITextField()
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleTextField)

        contentTextView = UITextView()
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentTextView)

        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = saveButton

        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 40),

            contentTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            contentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private func bindViewModel() {
        viewModel.memo
            .subscribe(onNext: { [weak self] memo in
                self?.titleTextField.text = memo.title
                self?.contentTextView.text = memo.content
            })
            .disposed(by: disposeBag)
    }

    @objc private func saveButtonTapped() {
        guard let title = titleTextField.text, let content = contentTextView.text else { return }
        viewModel.updateMemo(title: title, content: content)
    }
}


