//
// Created by Takaaki Hirano on 2017/05/14.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

enum RealmChange<T:RealmSwift.Object> {
    case initial(results: Results<T>)
    case deletions(rows: [Int])
    case insertions(rows: [Int])
    case modifications(rows: [Int])
}

protocol TimelineViewModelOutputs {
    var tweets: BehaviorSubject<RealmChange<Tweet>> { get }
}

protocol TimelineViewModelType {
    var outputs: TimelineViewModelOutputs { get }
}

final class TimelineViewModel: TimelineViewModelType, TimelineViewModelOutputs {
    
    // MARK: - Properties -
    
    var outputs: TimelineViewModelOutputs { return self }
    fileprivate var token: NotificationToken?
    fileprivate let tweetResults = try! Realm().objects(Tweet.self)
    
    
    // MARK: - Outputs -
    
    lazy var tweets: BehaviorSubject<RealmChange<Tweet>> = {
        return BehaviorSubject<RealmChange<Tweet>>(
            value: .initial(results: self.tweetResults)
        )
    }()
    
    
    // MARK: - Life Cycle Events -
    
    init() {
        setupNotificationToken()
    }
    
    deinit {
        token?.stop()
    }
}


// MARK: - Setup -

extension TimelineViewModel {
    
    fileprivate func setupNotificationToken() {
        token = tweetResults.addNotificationBlock { [weak self] change in
            guard let tweets = self?.tweets, let results = self?.tweetResults else { return }
            
            switch change {
            case .initial(results):
                tweets.onNext(.initial(results: results))
            case .update(results, let deletions, let insertions, let modifications):
                tweets.onNext(.deletions(rows: deletions))
                tweets.onNext(.insertions(rows: insertions))
                tweets.onNext(.modifications(rows: modifications))
            case .error(let error):
                tweets.onError(error)
            default:
                break
            }
        }
    }
}
