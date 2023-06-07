//
//  MemoDetailViewModel.swift
//  MemoProject
//
//  Created by Kant on 2023/06/03.
//

import RxSwift

class MemoDetailViewModel {
    private let memoRepository: MemoRepository
    private let disposeBag = DisposeBag()

    // Inputs
    let memo: BehaviorSubject<Memo>

    init(memo: Memo, memoRepository: MemoRepository) {
        self.memo = BehaviorSubject(value: memo)
        self.memoRepository = memoRepository
    }

    // Actions
    func updateMemo(title: String, content: String) {
        guard var memo = try? memo.value() else { return }
        memo.title = title
        memo.content = content

        memoRepository.update(memo: memo)
            .subscribe(onNext: { [weak self] in
                self?.memo.onNext(memo)
            })
            .disposed(by: disposeBag)
    }

    func deleteMemo() {
        guard let memo = try? memo.value() else { return }

        memoRepository.delete(memo: memo)
            .subscribe(onCompleted: { [weak self] in
                self?.memo.onCompleted()
            })
            .disposed(by: disposeBag)
    }
}
