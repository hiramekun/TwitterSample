//
// Created by Takaaki Hirano on 2017/05/13.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import UIKit
import SnapKit

final class CreateTweetViewController: UIViewController {
    
    // MARK: - Views -
    
    fileprivate lazy var textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .gray
        return textField
    }()
}


// MARK: - Life Cycle Events -

extension CreateTweetViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        setupView()
        setupLayout()
    }
}


// MARK: - Setup -

extension CreateTweetViewController {
    
    fileprivate func configure() {
        view.backgroundColor = .white
    }
    
    fileprivate func setupView() {
        view.addSubview(textField)
    }
    
    fileprivate func setupLayout() {
        textField.snp.makeConstraints { make in
            make.left.equalTo(view).inset(32)
            make.top.equalTo(view).inset(96)
            make.width.equalTo(200)
            make.height.equalTo(32)
        }
    }
}
