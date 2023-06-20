//
//  MemoUseCase.swift
//  MemoProject
//
//  Created by Kant on 2023/06/20.
//

import RxSwift

protocol MemoUseCase {
    func createMemo(title: String, content: String) -> Observable<Memo>
    func readMemoList() -> Observable<[Memo]>
    func updateMemo(memo: Memo) -> Observable<Void>
    func deleteMemo(memo: Memo) -> Observable<Void>
}

class DefaultMemoUseCase: MemoUseCase {
    private let repository: MemoRepository
    
    init(repository: MemoRepository) {
        self.repository = repository
    }
    
    func createMemo(title: String, content: String) -> Observable<Memo> {
        let newMemo = Memo(id: UUID().uuidString, title: title, content: content)
        return repository.create(memo: newMemo)
    }
    
    func readMemoList() -> Observable<[Memo]> {
        return repository.readAll()
    }
    
    func updateMemo(memo: Memo) -> Observable<Void> {
        return repository.update(memo: memo)
    }
    
    func deleteMemo(memo: Memo) -> Observable<Void> {
        return repository.delete(memo: memo)
    }
}
