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
    
    
    // MARK: - Outputs -
    
    let tweetVariable: Variable<Results<Tweet>> = {
        return Variable<Results<Tweet>>(try! Realm().objects(Tweet.self))
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
            guard let tweetVariable = self?.tweetVariable,
                  let tweetResults = self?.tweetVariable.value else { return }
            
            switch change {
            case .initial, .update:
                tweetVariable.value = tweetResults
            default:
                break
            }
        }
    }
}
