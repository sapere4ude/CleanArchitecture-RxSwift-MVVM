//
//  MemoListViewModel.swift
//  MemoProject
//
//  Created by Kant on 2023/06/03.
//

import RxSwift
import RxCocoa

class MemoListViewModel {
    
// MemoRepository는 의존성 역전 원칙이 사용된 레퍼지토리.
// 필요에 따라 다른 데이터 저장소로 교체하고자 할 때 MemoListViewModel 의 변경이 필요하지 않은 구조를 뜻한다.
// 만약 교체가 필요하다면? MemoRepository 프로토콜을 준수하는 새로운 구현체를 작성하고 MemoListViewModel의 생성자에 해당 구현체를 주입하면 된다!
    
    private let memoRepository: MemoRepository
    private let disposeBag = DisposeBag()

    let memos = BehaviorRelay<[Memo]>(value: []) // BehaviorRelay 는 RxSwift에서 제공하는 BehaviorSubject를 래핑한 클래스로, Observable의 일종이다. BehaviorRelay 는 상태를 유지하고 업데이트 하는데 유용하다. Observable의 구독자에게 항상 최신의 값을 전달하고, 직접 값을 업데이트 할 수 있다. 그렇기 때문에 UI 업데이트가 필요할때 사용하게 된다.

    init(memoRepository: MemoRepository) {
        self.memoRepository = memoRepository // MemoRepository 프로토콜을 준수하면 되는거라 현재는 MemoRepositoryImpl 클래스가 주입되어 사용된다.
        
        memoRepository.readAll()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] memos in
                self?.memos.accept(memos) // Subject에선 onNext를 사용하고, Relay에선 accept를 사용한다.
            })
            .disposed(by: disposeBag)
    }
    
    func createMemo(title: String, content: String) -> Observable<Memo> {
        let memo = Memo(id: UUID().uuidString, title: title, content: content)
        return memoRepository.create(memo: memo)
    }
    
    func loadMemos() {
        memoRepository.readAll()
            .subscribe(onNext: { [weak self] memos in
                self?.memos.accept(memos)
            })
            .disposed(by: disposeBag)
    }
}
