// // Created by Takaaki Hirano on 2017/05/26.
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
    var commentsVariable: Variable<Results<Comment>?> { get }
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
    fileprivate var token: NotificationToken?
    fileprivate let comments: Results<Comment>?
    
    
    // MARK: - Inputs -
    
    let submit = PublishSubject<String>()
    
    
    // MARK: - OutPuts -
    
    let commentsVariable: Variable<Results<Comment>?>
    
    
    // MARK: - Initializers -
    
    init(tweetId: String) {
        comments = try! Realm().object(ofType: Tweet.self, forPrimaryKey: tweetId)?
            .comments.sorted(byKeyPath: "createdAt", ascending: true)
        commentsVariable = Variable<Results<Comment>?>(comments)
        setupNotificationToken()
        setupBindings(tweetId: tweetId)
    }
    
    deinit {
        token?.stop()
    }
}


// MARK: - Setup -

extension TweetDetailViewModel {
    
    fileprivate func setupNotificationToken() {
        token = comments?.addNotificationBlock { [weak self] change in
            
            guard let comments = self?.comments else { return }
            switch change {
            case .initial, .update:
                self?.commentsVariable.value = comments
            default:
                break
            }
        }
    }
    
    fileprivate func setupBindings(tweetId: String) {
        submit.subscribe(onNext: { [weak self] string in
                self?.createComment(content: string, tweetId: tweetId)
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
