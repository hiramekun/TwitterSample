//
// Created by Takaaki Hirano on 2017/05/14.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

protocol CreateTweetViewModelInputs {
    var submit: PublishSubject<String> { get }
}

protocol CreateTweetViewModelType {
    var inputs: CreateTweetViewModelInputs { get }
}

final class CreateTweetViewModel: CreateTweetViewModelType, CreateTweetViewModelInputs {
    
    // MARK: - Properties -
    
    var inputs: CreateTweetViewModelInputs { return self }
    fileprivate let disposeBag = DisposeBag()
    
    
    // MARK: - Inputs -
    
    let submit = PublishSubject<String>()
    
    
    // MARK: - Initializers -
    
    init() {
        setupBindings()
    }
}


extension CreateTweetViewModel {
    
    fileprivate func setupBindings() {
        submit.asObservable()
            .subscribe(onNext: { [weak self] string in
                self?.saveTweet(content: string)
            })
            .disposed(by: disposeBag)
    }
    
    private func saveTweet(content: String) {
        let realm = try! Realm()
        try! realm.write {
            let tweet = Tweet(value: ["content": content])
            realm.add(tweet)
        }
    }
}
