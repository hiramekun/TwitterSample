//
// Created by Takaaki Hirano on 2017/05/13.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class TimelineViewController: UIViewController {
   
    // MARK: - Views -
    
    fileprivate lazy var tableView = UITableView()
    
    fileprivate lazy var postButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.clipsToBounds = true
        button.layer.cornerRadius = 28
        
        return button
    }()
}


// MARK: - Life Cycle Events -

extension TimelineViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupLayout()
    }
}


// MARK: - Setup -

extension TimelineViewController {
    
    fileprivate func setupView() {
        view.addSubview(tableView)
        view.addSubview(postButton)
    }
    
    fileprivate func setupLayout() {
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        postButton.snp.makeConstraints { (make) in
            make.right.bottom.equalTo(view).inset(16)
            make.size.equalTo(56)
        }
    }
}
