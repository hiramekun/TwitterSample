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

protocol CreateTweetViewModelOutputs {
    var created: PublishSubject<Void> { get }
}

protocol CreateTweetViewModelType {
    var inputs: CreateTweetViewModelInputs { get }
    var outputs: CreateTweetViewModelOutputs { get }
}

final class CreateTweetViewModel: CreateTweetViewModelType, CreateTweetViewModelInputs, CreateTweetViewModelOutputs {
    
    // MARK: - Properties -
    
    var inputs: CreateTweetViewModelInputs { return self }
    var outputs: CreateTweetViewModelOutputs { return self }
    fileprivate let disposeBag = DisposeBag()
    
    
    // MARK: - Inputs -
    
    let submit = PublishSubject<String>()
    
    
    // MARK: - Outputs -
    
    let created = PublishSubject<Void>()
    
    
    // MARK: - Initializers -
    
    init() {
        setupBindings()
    }
}


// MARK: - Setup -

extension CreateTweetViewModel {
    
    fileprivate func setupBindings() {
        submit.subscribe(onNext: { [weak self] string in
                self?.createTweet(content: string)
                self?.created.onNext()
            })
            .disposed(by: disposeBag)
    }
    
    private func createTweet(content: String) {
        let realm = try! Realm()
        try! realm.write {
            let tweet = Tweet()
            tweet.content = content
            realm.add(tweet)
        }
    }
}
