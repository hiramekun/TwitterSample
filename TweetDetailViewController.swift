//
// Created by Takaaki Hirano on 2017/05/22.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import UIKit
import RealmSwift
import SnapKit
import RxSwift
import RxCocoa

fileprivate enum CellIdentifier: String {
    case uiTableViewCell = "UITableViewCell"
}

final class TweetDetailViewController: UIViewController {
    
    // MARK: - Properties -
    
    fileprivate let tweetId: String
    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModel: TweetDetailViewModelType
    
    
    // MARK: - Views -
    
    fileprivate lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .lightGray
        label.numberOfLines = 0
        label.text = try! Realm().object(ofType: Tweet.self, forPrimaryKey: self.tweetId)?.content
        label.textAlignment = .center
        return label
    }()
    
    fileprivate lazy var inputCommentTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .lightGray
        return textField
    }()
    
    fileprivate lazy var submitCommentButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blue
        return button
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
    
    init(tweetId: String, viewModel: TweetDetailViewModelType) {
        self.tweetId = tweetId
        self.viewModel = viewModel
        
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
        subscribeView()
        subscribeViewModel()
    }
}


// MARK: - Setup -

extension TweetDetailViewController {
    
    fileprivate func configure() {
        view.backgroundColor = .white
    }
    
    fileprivate func setupView() {
        view.addSubview(contentLabel)
        view.addSubview(inputCommentTextField)
        view.addSubview(submitCommentButton)
        view.addSubview(commentsTableView)
    }
    
    fileprivate func setupLayout() {
        contentLabel.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.left.right.equalTo(view).inset(16)
        }
        
        inputCommentTextField.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(contentLabel.snp.bottom).offset(16)
            make.width.equalTo(200)
            make.height.equalTo(32)
        }
        
        submitCommentButton.snp.makeConstraints { make in
            make.left.equalTo(inputCommentTextField.snp.right).offset(12)
            make.centerY.equalTo(inputCommentTextField)
            make.width.height.equalTo(32)
        }
        
        commentsTableView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(inputCommentTextField.snp.bottom).offset(32)
        }
    }
    
    fileprivate func subscribeView() {
        submitCommentButton.rx.tap
            .filter { [weak self] in
                self?.inputCommentTextField.text?.isEmpty == false
            }
            .subscribe(onNext: { [weak self] in
                guard let unwrappedSelf = self else { return }
                unwrappedSelf.viewModel.inputs.submit
                    .onNext(unwrappedSelf.inputCommentTextField.text!)
            })
            .disposed(by: disposeBag)
    }
    
    fileprivate func subscribeViewModel() {
        viewModel.outputs.commentsVariable.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.commentsTableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}


// MARK: - UITableViewDataSource -

extension TweetDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let comments = viewModel.outputs.commentsVariable.value else { return 0 }
        return comments.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CellIdentifier.uiTableViewCell.rawValue, for: indexPath)
        cell.textLabel?.text = viewModel.outputs.commentsVariable.value?[indexPath.row].content
        return cell
    }
}
