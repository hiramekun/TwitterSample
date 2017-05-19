//
// Created by Takaaki Hirano on 2017/05/14.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import Foundation
import RxSwift

protocol CreateTweetViewModelInputs {
    var submit: PublishSubject<String> { get }
}

protocol CreateTweetViewModelType {
    var inputs: CreateTweetViewModelInputs { get }
}

final class CreateTweetViewModel: CreateTweetViewModelInputs {
    
    // MARK: - Properties -
    
    var inputs: CreateTweetViewModelInputs { return self }
    fileprivate let disposeBag = DisposeBag()
    
    
    // MARK: - Inputs -
    
    let submit = PublishSubject<String>()
    
    
    // MARK: - Initializers -
    
    init() {
        setupBindings()
    }
}


extension CreateTweetViewModel {
    
    fileprivate func setupBindings() {
        submit.subscribe(onNext: { string in
                // TODO: save to realm in repository class
            })
            .disposed(by: disposeBag)
    }
}
