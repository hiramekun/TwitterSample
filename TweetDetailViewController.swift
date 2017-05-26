//
// Created by Takaaki Hirano on 2017/05/22.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import UIKit
import RealmSwift
import SnapKit

fileprivate enum CellIdentifier: String {
    case uiTableViewCell = "UITableViewCell"
}

final class TweetDetailViewController: UIViewController {
    
    // MARK: - Properties -
    
    fileprivate let tweetId: String
    
    
    // MARK: - Views -
    
    fileprivate lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .lightGray
        label.numberOfLines = 0
        label.text = try! Realm().object(ofType: Tweet.self, forPrimaryKey: self.tweetId)?.content
        label.textAlignment = .center
        return label
    }()
    
    fileprivate lazy var commentsTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: CellIdentifier.uiTableViewCell.rawValue)
        tableView.rowHeight = 40
        tableView.dataSource = self
        
        return tableView
    }()
    
    
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
        view.addSubview(contentLabel)
        view.addSubview(commentsTableView)
    }
    
    fileprivate func setupLayout() {
        contentLabel.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.left.right.equalTo(view).inset(16)
        }
        
        commentsTableView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(contentLabel.snp.bottom).offset(32)
        }
    }
}


// MARK: - UITableViewDataSource -

extension TweetDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO: Implement
        return 0
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO: Implement
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CellIdentifier.uiTableViewCell.rawValue, for: indexPath)
        return cell
    }
}
