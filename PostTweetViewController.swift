//
// Created by Takaaki Hirano on 2017/05/13.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import UIKit
import SnapKit

final class PostTweetViewController: UIViewController {
    
    // MARK: - Views -
    
    fileprivate lazy var textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .gray
        return textField
    }()
    
    
    // MARK: - Initializer -
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Life Cycle Events -

extension PostTweetViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupLayout()
    }
}


// MARK: - Setup -

extension PostTweetViewController {
    
    fileprivate func setupView() {
        view.addSubview(textField)
    }
    
    fileprivate func setupLayout() {
        textField.snp.makeConstraints { make in
            make.top.equalTo(view).inset(96)
            make.left.equalTo(view).inset(32)
            make.width.equalTo(200)
            make.height.equalTo(32)
        }
    }
}
