//
// Created by Takaaki Hirano on 2017/05/14.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

protocol TimelineViewModelOutputs {
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
        .sorted(byKeyPath: "createdAt", ascending: false)
    
    
    // MARK: - Outputs -
    
    let tweetVariable: Variable<Results<Tweet>>
    
    
    // MARK: - Life Cycle Events -
    
    init() {
        tweetVariable = Variable(tweetResults)
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
            
            guard let tweetResults = self?.tweetResults else { return }
            switch change {
            case .initial, .update:
                self?.tweetVariable.value = tweetResults
            default:
                break
            }
        }
    }
}
