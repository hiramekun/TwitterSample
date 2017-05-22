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
    var tweetChanges: BehaviorSubject<RealmChange<Tweet>> { get }
    var tweetVariable: Variable<Results<Tweet>> { get }
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
    
    lazy var tweetVariable: Variable<Results<Tweet>> = {
        return Variable<Results<Tweet>>(self.tweetResults)
    }()
    
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
        token = tweetVariable.value.addNotificationBlock { [weak self] change in
            guard let tweetChanges = self?.tweetChanges, let tweetResults = self?.tweetVariable.value else { return }
            
            switch change {
            case .initial(tweetResults):
                tweetChanges.onNext(.initial(results: tweetResults))
            case .update(tweetResults, let deletions, let insertions, let modifications):
                if deletions.count > 0 { tweetChanges.onNext(.deletions(rows: deletions)) }
                if insertions.count > 0 { tweetChanges.onNext(.insertions(rows: insertions)) }
                if modifications.count > 0 { tweetChanges.onNext(.modifications(rows: modifications)) }
            case .error(let error):
                tweetChanges.onError(error)
            default:
                break
            }
        }
    }
}
