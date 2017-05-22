//
// Created by Takaaki Hirano on 2017/05/22.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import UIKit

final class TweetDetailViewController: UIViewController {
    
    // MARK: - Properties -
    let tweetId: String
    
    
    // MARK: - Initializers -
    
    init(tweetId: String) {
        self.tweetId = tweetId
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError()
    }
}


// MARK: -  Life Cycle Events -

extension TweetDetailViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        setupView()
        setupLayout()
    }
}


// MARK: - Setup -

extension TweetDetailViewController {
    
    fileprivate func configure() {
        view.backgroundColor = .white
    }
    
    fileprivate func setupView() {
    
    }
    
    fileprivate func setupLayout() {
        
    }
}
