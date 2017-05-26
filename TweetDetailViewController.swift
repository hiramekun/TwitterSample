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
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModel: TweetDetailViewModelType
    
    
    // MARK: - Views -
    
    fileprivate lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .lightGray
        label.numberOfLines = 0
        label.text = self.viewModel.outputs.tweetVariable.value.content
        label.textAlignment = .center
        return label
    }()
    
    fileprivate lazy var commentTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .lightGray
        return textField
    }()
    
    fileprivate lazy var submitCommentButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blue
        return button
    }()
    
    fileprivate lazy var deleteTweetButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        return button
    }()
    
    fileprivate lazy var commentsTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: CellIdentifier.uiTableViewCell.rawValue
        )
        tableView.rowHeight = 40
        tableView.dataSource = self
        tableView.delegate = self
        
        return tableView
    }()
    
    
    // MARK: - Initializers -
    
    init(viewModel: TweetDetailViewModelType) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    
    // MARK: - Override Methods -
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        commentsTableView.isEditing = editing
    }
}


// MARK: -  Life Cycle Events -

extension TweetDetailViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem
        
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
        view.addSubview(commentTextField)
        view.addSubview(submitCommentButton)
        view.addSubview(deleteTweetButton)
        view.addSubview(commentsTableView)
    }
    
    fileprivate func setupLayout() {
        contentLabel.snp.makeConstraints { make in
            make.center.equalTo(view)
            make.left.right.equalTo(view).inset(16)
        }
        
        commentTextField.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(contentLabel.snp.bottom).offset(16)
            make.width.equalTo(200)
            make.height.equalTo(32)
        }
        
        submitCommentButton.snp.makeConstraints { make in
            make.left.equalTo(commentTextField.snp.right).offset(12)
            make.centerY.equalTo(commentTextField)
            make.width.height.equalTo(32)
        }
        
        deleteTweetButton.snp.makeConstraints { make in
            make.left.equalTo(submitCommentButton.snp.right).offset(12)
            make.centerY.equalTo(submitCommentButton)
            make.width.height.equalTo(32)
        }
        
        commentsTableView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(commentTextField.snp.bottom).offset(32)
        }
    }
    
    fileprivate func subscribeView() {
        submitCommentButton.rx.tap
            .filter { [weak self] in
                self?.commentTextField.text?.isEmpty == false
            }
            .subscribe(onNext: { [weak self] in
                guard let unwrappedSelf = self else { return }
                
                unwrappedSelf.viewModel.inputs.submit
                    .onNext(unwrappedSelf.commentTextField.text!)
                unwrappedSelf.commentTextField.text = ""
            })
            .disposed(by: disposeBag)
        
        deleteTweetButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.inputs.deleteTweet.onNext()
            })
            .disposed(by: disposeBag)
    }
    
    fileprivate func subscribeViewModel() {
        viewModel.outputs.commentsVariable.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.commentsTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.deleteTweetSuccess
            .subscribe(onNext: { [weak self] isSuccess in
                if isSuccess {
                    _ = self?.navigationController?.popViewController(animated: true)
                }
                else {
                    let alertView = UIAlertController(title: "削除失敗", message: "ツイートの削除に失敗しました",
                                                      preferredStyle: .alert)
                    alertView.addAction(UIAlertAction(title: "OK", style: .cancel))
                    self?.present(alertView, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
}


// MARK: - UITableViewDataSource -

extension TweetDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.outputs.commentsVariable.value.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CellIdentifier.uiTableViewCell.rawValue, for: indexPath
        )
        cell.textLabel?.text = viewModel.outputs.commentsVariable.value[indexPath.row].content
        return cell
    }
}


// MARK: - UITableViewDelegate -

extension TweetDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCellEditingStyle,
                   forRowAt indexPath: IndexPath) {
        viewModel.inputs.deleteComment.onNext(
            viewModel.outputs.commentsVariable.value[indexPath.row].id
        )
    }
}
