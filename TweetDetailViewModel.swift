// // Created by Takaaki Hirano on 2017/05/26.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift

protocol TweetDetailViewModelInputs {
    var submit: PublishSubject<String> { get }
    var deleteTweet: PublishSubject<Void> { get }
    var deleteComment: PublishSubject<String> { get }
}

protocol TweetDetailViewModelOutputs {
    var commentsVariable: Variable<Results<Comment>> { get }
    var tweet: Tweet { get }
}

protocol TweetDetailViewModelType {
    var inputs: TweetDetailViewModelInputs { get }
    var outputs: TweetDetailViewModelOutputs { get }
}

final class TweetDetailViewModel: TweetDetailViewModelType, TweetDetailViewModelInputs, TweetDetailViewModelOutputs {
    
    // MARK: - Properties -
    
    var inputs: TweetDetailViewModelInputs { return self }
    var outputs: TweetDetailViewModelOutputs { return self }
    let tweet: Tweet
    fileprivate let realm = try! Realm()
    fileprivate let disposeBag = DisposeBag()
    fileprivate var token: NotificationToken?
    fileprivate let comments: Results<Comment>
    
    
    // MARK: - Inputs -
    
    let submit = PublishSubject<String>()
    let deleteTweet = PublishSubject<Void>()
    let deleteComment = PublishSubject<String>()
    
    
    // MARK: - OutPuts -
    
    let commentsVariable: Variable<Results<Comment>>
    
    
    // MARK: - Initializers -
    
    init(tweetID: String) {
        tweet = realm.object(ofType: Tweet.self, forPrimaryKey: tweetID)!
        comments = tweet.comments.sorted(byKeyPath: "createdAt", ascending: true)
        commentsVariable = Variable<Results<Comment>>(comments)
        setupNotificationToken()
        setupBindings()
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
    
    fileprivate func setupBindings() {
        deleteTweet.subscribe(onNext: { [weak self] in
                self?.executeDeleteTweet()
            })
            .disposed(by: disposeBag)
        
        deleteComment.subscribe(onNext: { [weak self] id in
                self?.executeDeleteComment(commentID: id)
            })
            .disposed(by: disposeBag)
        
        submit.subscribe(onNext: { [weak self] string in
                self?.executeCreateComment(content: string)
            })
            .disposed(by: disposeBag)
    }
    
    private func executeDeleteTweet() {
        try! realm.write {
            realm.delete(tweet)
        }
    }
    
    private func executeDeleteComment(commentID: String) {
        try! realm.write {
            guard let comment = realm.object(ofType: Comment.self, forPrimaryKey: commentID)
                else { return }
            
            realm.delete(comment)
        }
    }
    
    private func executeCreateComment(content: String) {
        try! realm.write {
            let comment = Comment()
            comment.content = content
            tweet.comments.append(comment)
        }
    }
}
