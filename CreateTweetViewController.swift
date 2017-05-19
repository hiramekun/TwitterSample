//
// Created by Takaaki Hirano on 2017/05/13.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

final class CreateTweetViewController: UIViewController {
    
    // MARK: - Properties -
    
    fileprivate let createTweetViewModelType: CreateTweetViewModelType
    fileprivate let disposeBag = DisposeBag()
    
    
    // MARK: - Views -
    
    fileprivate lazy var textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .gray
        return textField
    }()
    
    fileprivate lazy var submitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blue
        return button
    }()
    
    
    // MARK: - Initializers -
    
    init(viewModel: CreateTweetViewModelType) {
        createTweetViewModelType = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError()
    }
}


// MARK: - Life Cycle Events -

extension CreateTweetViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        setupView()
        setupLayout()
        setupBindings()
    }
}


// MARK: - Setup -

extension CreateTweetViewController {
    
    fileprivate func configure() {
        view.backgroundColor = .white
    }
    
    fileprivate func setupView() {
        view.addSubview(textField)
        view.addSubview(submitButton)
    }
    
    fileprivate func setupLayout() {
        textField.snp.makeConstraints { make in
            make.left.equalTo(view).inset(32)
            make.top.equalTo(view).inset(96)
            make.width.equalTo(200)
            make.height.equalTo(32)
        }
        
        submitButton.snp.makeConstraints { make in
            make.left.equalTo(textField.snp.right).offset(32)
            make.top.equalTo(textField)
            make.width.height.equalTo(textField.snp.height)
        }
    }
    
    fileprivate func setupBindings() {
        
        submitButton.rx.tap
            .filter { [weak self] in
                guard let text = self?.textField.text else { return false }
                return !text.isEmpty
            }
            .subscribe(onNext: { [weak self] in
                guard  let unwrappedSelf = self else { return }
                unwrappedSelf.createTweetViewModelType.inputs.submit
                    .onNext(unwrappedSelf.textField.text!)
            })
            .disposed(by: disposeBag)
        
        createTweetViewModelType.outputs.created
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
