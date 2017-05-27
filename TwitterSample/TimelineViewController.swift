//
// Created by Takaaki Hirano on 2017/05/13.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import RealmSwift

fileprivate enum CellIdentifier: String {
    case tweetTableViewCell = "TweetTableViewCell"
}

final class TimelineViewController: UIViewController {
    
    // MARK: - Properties -
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModel: TimelineViewModelType
    
    
    // MARK: - Views -
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(
            TweetTableViewCell.self,
            forCellReuseIdentifier: CellIdentifier.tweetTableViewCell.rawValue
        )
        tableView.rowHeight = 40
        tableView.dataSource = self
        tableView.delegate = self
        
        return tableView
    }()
    
    fileprivate lazy var postButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.clipsToBounds = true
        button.layer.cornerRadius = 28
        
        return button
    }()
    
    
    // MARK: - Initializers -
    
    init(viewModel: TimelineViewModelType) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError()
    }
}


// MARK: - Life Cycle Events -

extension TimelineViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupLayout()
        subscribeView()
        subscribeViewModel()
    }
}


// MARK: - Setup -

extension TimelineViewController {
    
    fileprivate func setupView() {
        view.addSubview(tableView)
        view.addSubview(postButton)
    }
    
    fileprivate func setupLayout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        postButton.snp.makeConstraints { make in
            make.right.bottom.equalTo(view).inset(16)
            make.size.equalTo(56)
        }
    }
    
    fileprivate func subscribeView() {
        postButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.pushViewController(
                    CreateTweetViewController(viewModel: CreateTweetViewModel()),
                    animated: true
                )
            })
            .disposed(by: disposeBag)
    }
    
    fileprivate func subscribeViewModel() {
        viewModel.outputs.tweetVariable.asObservable()
            .subscribe { [weak self] _ in
                guard let tableView = self?.tableView else { return }
                tableView.reloadData()
            }
            .disposed(by: disposeBag)
    }
}


// MARK: - UITableViewDataSource -

extension TimelineViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.outputs.tweetVariable.value.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CellIdentifier.tweetTableViewCell.rawValue, for: indexPath
        ) as! TweetTableViewCell
        
        if indexPath.row < viewModel.outputs.tweetVariable.value.count {
            let tweet = viewModel.outputs.tweetVariable.value[indexPath.row]
            cell.update(tweet: tweet)
        }
        return cell
    }
}


// MARK: - UITableViewDelegate -

extension TimelineViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tweetID = viewModel.outputs.tweetVariable.value[indexPath.row].id
        let tweetDetailViewController = TweetDetailViewController(
            viewModel: TweetDetailViewModel(tweetID: tweetID)
        )
        navigationController?.pushViewController(tweetDetailViewController, animated: true)
    }
}
