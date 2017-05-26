//
// Created by Takaaki Hirano on 2017/05/26.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift

protocol TweetDetailViewModelInputs {
    var submit: PublishSubject<String> { get }
}

protocol TweetDetailViewModelOutputs {
    var created: PublishSubject<Void> { get }
}

protocol TweetDetailViewModelType {
    var inputs: TweetDetailViewModelInputs { get }
    var outputs: TweetDetailViewModelOutputs { get }
}

final class TweetDetailViewModel: TweetDetailViewModelType, TweetDetailViewModelInputs, TweetDetailViewModelOutputs {
    
    // MARK: - Properties -
    
    var inputs: TweetDetailViewModelInputs { return self }
    var outputs: TweetDetailViewModelOutputs { return self }
    fileprivate let disposeBag = DisposeBag()
    
    // MARK: - Inputs -
    
    let submit = PublishSubject<String>()
    
    
    // MARK: - OutPuts -
    
    let created = PublishSubject<Void>()
    
    
    // MARK: - Initializers -
    
    init(tweetId: String) {
        setupBindings(tweetId: tweetId)
    }
}


// MARK: - Setup -

extension TweetDetailViewModel {
    
    fileprivate func setupBindings(tweetId: String) {
        submit.subscribe(onNext: { [weak self] string in
                self?.createComment(content: string, tweetId: tweetId)
                self?.created.onNext()
            })
            .disposed(by: disposeBag)
    }
    
    private func createComment(content: String, tweetId: String) {
        let realm = try! Realm()
        try! realm.write {
            let comment = Comment()
            comment.content = content
            realm.object(ofType: Tweet.self, forPrimaryKey: tweetId)?.comments.append(comment)
        }
    }
}
