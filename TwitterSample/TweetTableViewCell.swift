//
// Created by Takaaki Hirano on 2017/05/26.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import UIKit
import SnapKit

final class TweetTableViewCell: UITableViewCell {
    
    // MARK: - Views -
    
    fileprivate lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    fileprivate lazy var latestCommentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    
    // MARK: - Initializers -
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
        setupLayout()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError()
    }
}


// MARK: - Setup -

extension TweetTableViewCell {
    
    fileprivate func setupView() {
        addSubview(contentLabel)
        addSubview(latestCommentLabel)
    }
    
    fileprivate func setupLayout() {
        contentLabel.snp.makeConstraints { make in
            make.left.top.right.equalTo(self).inset(4)
            make.height.equalTo(18)
        }
        
        latestCommentLabel.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(4)
            make.left.right.bottom.equalTo(self).inset(4)
            make.height.equalTo(14)
        }
    }
}


// MARK: - Update View -

extension TweetTableViewCell {
    
    func update(tweet: Tweet) {
        contentLabel.text = tweet.content
        latestCommentLabel.text = tweet.comments
            .sorted(byKeyPath: "createdAt", ascending: false).first?.content
    }
}
