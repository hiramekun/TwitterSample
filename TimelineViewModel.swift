//
// Created by Takaaki Hirano on 2017/05/14.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

protocol TimelineViewModelInputs {
    var tweetContent: Variable<String> { get }
}

protocol TimelineViewModelOutputs {
    var tweets: Variable<Results<Tweet>> { get }
}

protocol TimelineViewModelType {
    var inputs: TimelineViewModelInputs { get }
    var outputs: TimelineViewModelOutputs { get }
}

final class TimelineViewModel: TimelineViewModelInputs, TimelineViewModelOutputs {
    
    // MARK: - Properties -
    
    var inputs: TimelineViewModelInputs { return self }
    var outputs: TimelineViewModelOutputs { return self }
    let disposeBag = DisposeBag()
    
    
    // MARK: - Inputs -
    
    let tweetContent = Variable<String>("")
    
    
    // MARK: - Outputs -
    
    lazy var tweets: Variable<Results<Tweet>> = {
        return Variable(try! Realm().objects(Tweet.self))
    }()
    
    
    // MARK: - Initializers -
    
    init() {
        setupBindings()
    }
}


extension TimelineViewModel {
    
    fileprivate func setupBindings() {
        tweetContent.asObservable()
            .subscribe(onNext: { string in
                // TODO: save to realm in repository class
            })
            .disposed(by: disposeBag)
    }
}
