//
// Created by Takaaki Hirano on 2017/05/14.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import Foundation
import RxSwift

protocol CreateTweetViewModelInputs {
    var submit: Variable<String> { get }
}

protocol CreateTweetViewModelType {
    var inputs: CreateTweetViewModelInputs { get }
}

final class CreateTweetViewModel: CreateTweetViewModelInputs {
    
    // MARK: - Properties -
    
    var inputs: CreateTweetViewModelInputs { return self }
    let disposeBag = DisposeBag()
    
    
    // MARK: - Inputs -
    
    let submit = Variable<String>("")
    
    
    // MARK: - Initializers -
    
    init() {
        setupBindings()
    }
}


extension CreateTweetViewModel {
    
    fileprivate func setupBindings() {
        submit.asObservable()
            .subscribe(onNext: { string in
                // TODO: save to realm in repository class
            })
            .disposed(by: disposeBag)
    }
}
