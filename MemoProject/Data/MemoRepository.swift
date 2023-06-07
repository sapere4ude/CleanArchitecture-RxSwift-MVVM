//
//  MemoRepository.swift
//  MemoProject
//
//  Created by Kant on 2023/06/03.
//

import RxSwift

protocol MemoRepository {
    func create(memo: Memo) -> Observable<Memo>
    func readAll() -> Observable<[Memo]>
    func update(memo: Memo) -> Observable<Void>
    func delete(memo: Memo) -> Observable<Void>
}

class MemoRepositoryImpl: MemoRepository {
    private var memos: [Memo] = []

    func create(memo: Memo) -> Observable<Memo> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            var memos = self.getMemosFromUserDefaults()
            
            let newMemo = memo
            memos.append(newMemo)
            
            self.saveMemosToUserDefaults(memos)
            
            observer.onNext(newMemo)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    func readAll() -> Observable<[Memo]> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            let memos = self.getMemosFromUserDefaults()
            
            observer.onNext(memos)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }

    func update(memo: Memo) -> Observable<Void> {
        return Observable.create { observer in
            if let index = self.memos.firstIndex(where: { $0.id == memo.id }) {
                self.memos[index] = memo
                observer.onNext(())
            }
            observer.onCompleted()
            return Disposables.create()
        }
    }

    func delete(memo: Memo) -> Observable<Void> {
        return Observable.create { observer in
            self.memos.removeAll { $0.id == memo.id }
            observer.onNext(())
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    private func getMemosFromUserDefaults() -> [Memo] {
        guard let memoData = UserDefaults().data(forKey: "Memos") else {
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            let memos = try decoder.decode([Memo].self, from: memoData)
            return memos
        } catch {
            return []
        }
    }
    
    private func saveMemosToUserDefaults(_ memos: [Memo]) {
        do {
            let encoder = JSONEncoder()
            let memoData = try encoder.encode(memos)
            UserDefaults().set(memoData, forKey: "Memos")
        } catch {
            // Handle error if needed
        }
    }
}
