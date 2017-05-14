//
// Created by Takaaki Hirano on 2017/05/14.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

protocol TimelineViewModelOutputs {
    var tweets: Variable<Results<Tweet>> { get }
}

protocol TimelineViewModelType {
    var outputs: TimelineViewModelOutputs { get }
}

final class TimelineViewModel: TimelineViewModelOutputs {
    
    // MARK: - Properties -
    
    var outputs: TimelineViewModelOutputs { return self }
    
    
    // MARK: - Outputs -
    
    lazy var tweets: Variable<Results<Tweet>> = {
        return Variable(try! Realm().objects(Tweet.self))
    }()
}
