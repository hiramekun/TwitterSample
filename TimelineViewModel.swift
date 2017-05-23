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
    
    func allResults() throws -> Results<T> {
        return try Realm().objects(T.self)
    }
}

protocol TimelineViewModelOutputs {
    var tweetChanges: BehaviorSubject<RealmChange<Tweet>> { get }
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
    
    lazy var tweetChanges: BehaviorSubject<RealmChange<Tweet>> = {
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
            guard let tweetChanges = self?.tweetChanges,
                  let tweetResults = self?.tweetResults else { return }
            
            switch change {
            case .initial(tweetResults):
                tweetChanges.onNext(.initial(results: tweetResults))
            case .update(tweetResults, let deletions, let insertions, let modifications):
                if deletions.count > 0 { tweetChanges.onNext(.deletions(rows: deletions)) }
                if insertions.count > 0 { tweetChanges.onNext(.insertions(rows: insertions)) }
                if modifications.count > 0 {
                    tweetChanges.onNext(.modifications(rows: modifications))
                }
            case .error(let error):
                tweetChanges.onError(error)
            default:
                break
            }
        }
    }
}
