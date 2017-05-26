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
    var tweetVariable: Variable<Tweet> { get }
    var deleteTweetSuccess: PublishSubject<Bool> { get }
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
    let deleteTweet = PublishSubject<Void>()
    let deleteComment = PublishSubject<String>()
    
    
    // MARK: - OutPuts -
    
    let commentsVariable: Variable<Results<Comment>>
    let tweetVariable: Variable<Tweet>
    let deleteTweetSuccess = PublishSubject<Bool>()
    
    
    // MARK: - Initializers -
    
    init(tweetID: String) {
        let tweet = realm.object(ofType: Tweet.self, forPrimaryKey: tweetID)!
        tweetVariable = Variable<Tweet>(tweet)
        comments = tweet.comments.sorted(byKeyPath: "createdAt", ascending: true)
        commentsVariable = Variable<Results<Comment>>(comments)
        setupNotificationToken()
        setupBindings(tweetID: tweetID)
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
    
    fileprivate func setupBindings(tweetID: String) {
        deleteTweet.subscribe(onNext: { [weak self] in
                self?.deleteTweet(tweetID: tweetID)
            })
            .disposed(by: disposeBag)
        
        deleteComment.subscribe(onNext: { [weak self] id in
                self?.deleteComment(commentID: id)
            })
            .disposed(by: disposeBag)
        
        submit.subscribe(onNext: { [weak self] string in
                self?.createComment(content: string, tweetID: tweetID)
            })
            .disposed(by: disposeBag)
    }
    
    private func deleteTweet(tweetID: String) {
        try! realm.write {
            guard let tweet = realm.object(ofType: Tweet.self, forPrimaryKey: tweetID)
                else {
                deleteTweetSuccess.onNext(false)
                return
            }
            
            realm.delete(tweet)
            deleteTweetSuccess.onNext(true)
        }
    }
    
    private func deleteComment(commentID: String) {
        try! realm.write {
            guard let comment = realm.object(ofType: Comment.self, forPrimaryKey: commentID)
                else { return }
            
            realm.delete(comment)
        }
    }
    
    private func createComment(content: String, tweetID: String) {
        try! realm.write {
            let comment = Comment()
            comment.content = content
            realm.object(ofType: Tweet.self, forPrimaryKey: tweetID)?.comments.append(comment)
        }
    }
}
