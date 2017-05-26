// // Created by Takaaki Hirano on 2017/05/26.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift

protocol TweetDetailViewModelInputs {
    var submit: PublishSubject<String> { get }
    var delete: PublishSubject<Void> { get }
}

protocol TweetDetailViewModelOutputs {
    var commentsVariable: Variable<Results<Comment>> { get }
    var tweetVariable: Variable<Tweet> { get }
    var deleteSuccess: PublishSubject<Bool> { get }
}

protocol TweetDetailViewModelType {
    var inputs: TweetDetailViewModelInputs { get }
    var outputs: TweetDetailViewModelOutputs { get }
}

final class TweetDetailViewModel: TweetDetailViewModelType, TweetDetailViewModelInputs, TweetDetailViewModelOutputs {
    
    // MARK: - Properties -
    
    var inputs: TweetDetailViewModelInputs { return self }
    var outputs: TweetDetailViewModelOutputs { return self }
    fileprivate let realm = try! Realm()
    fileprivate let disposeBag = DisposeBag()
    fileprivate var token: NotificationToken?
    fileprivate let comments: Results<Comment>
    
    
    // MARK: - Inputs -
    
    let submit = PublishSubject<String>()
    let deletion = PublishSubject<Void>()
    
    
    // MARK: - OutPuts -
    
    let commentsVariable: Variable<Results<Comment>>
    let tweetVariable: Variable<Tweet>
    let deleteSuccess = PublishSubject<Bool>()
    
    
    // MARK: - Initializers -
    
    init(tweetID: String) {
        let tweet = realm.object(ofType: Tweet.self, forPrimaryKey: tweetID)!
        tweetVariable = Variable<Tweet>(tweet)
        comments = tweet.comments.sorted(byKeyPath: "createdAt", ascending: true)
        commentsVariable = Variable<Results<Comment>>(comments)
        setupNotificationToken()
        setupBindings(tweetId: tweetID)
    }
    
    deinit {
        token?.stop()
    }
}


// MARK: - Setup -

extension TweetDetailViewModel {
    
    fileprivate func setupNotificationToken() {
        token = comments.addNotificationBlock { [weak self] change in
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
        delete.subscribe(onNext: { [weak self] in
                self?.deleteTweet(tweetId: tweetId)
            })
            .disposed(by: disposeBag)
        
        submit.subscribe(onNext: { [weak self] string in
                self?.createComment(content: string, tweetId: tweetId)
            })
            .disposed(by: disposeBag)
    }
    
    private func deleteTweet(tweetId: String) {
        try! realm.write {
            guard let target = realm.object(ofType: Tweet.self, forPrimaryKey: tweetId)
                else {
                deleteSuccess.onNext(false)
                return
            }
            
            realm.delete(target)
            deleteSuccess.onNext(true)
        }
    }
    
    private func createComment(content: String, tweetId: String) {
        try! realm.write {
            let comment = Comment()
            comment.content = content
            realm.object(ofType: Tweet.self, forPrimaryKey: tweetId)?.comments.append(comment)
        }
    }
}
