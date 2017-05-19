//
// Created by Takaaki Hirano on 2017/05/13.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import RealmSwift

final class TimelineViewController: UIViewController {
    
    // MARK: - Properties -
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModel: TimelineViewModelType
    
    
    // MARK: - Views -
    
    fileprivate lazy var tableView = UITableView()
    
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        setupView()
        setupLayout()
        setupBinding()
        setupTableViewBinding()
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
    
    fileprivate func setupTableViewBinding() {
        let dataSource = TimelineDataSource()
        viewModel.outputs.tweetVariable
            .asObservable()
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
    }
    
    fileprivate func setupBinding() {
        postButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.pushViewController(
                    CreateTweetViewController(viewModel: CreateTweetViewModel()),
                    animated: true
                )
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.tweetChanges
            .subscribe(onNext: { [weak self] change in
                guard let tableView = self?.tableView else { return }
                
                switch change {
                case .initial(_):
                    tableView.reloadData()
                
                case .deletions(let rows):
                    tableView.beginUpdates()
                    tableView.deleteRows(
                        at: rows.map { IndexPath(row: $0, section: 0) },
                        with: .fade
                    )
                    tableView.endUpdates()
                
                case .insertions(let rows):
                    tableView.beginUpdates()
                    tableView.insertRows(
                        at: rows.map { IndexPath(row: $0, section: 0) },
                        with: .fade
                    )
                    tableView.endUpdates()
                
                case .modifications(let rows):
                    tableView.beginUpdates()
                    tableView.reloadRows(
                        at: rows.map { IndexPath(row: $0, section: 0) },
                        with: .none
                    )
                    tableView.endUpdates()
                }
            })
            .disposed(by: disposeBag)
    }
}


final fileprivate class TimelineDataSource: NSObject {
    
    // MARK: - Properties -
    
    typealias Element = Results<Tweet>
    fileprivate var itemModels: Element = try! Realm().objects(Tweet.self)
    fileprivate let selectedIndexPath = PublishSubject<IndexPath>()
}


// MARK: - RxTableViewDataSourceType -

extension TimelineDataSource: RxTableViewDataSourceType {
    
    func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        UIBindingObserver(UIElement: self) { (dataSource, element) in
            dataSource.itemModels = element
            tableView.reloadData()
        }.on(observedEvent)
    }
}


// MARK: - UITableViewDelegate -

extension TimelineDataSource: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath.onNext(indexPath)
    }
    
}


// MARK: - UITableViewDataSource -

extension TimelineDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemModels.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = itemModels[indexPath.row].content
        return cell
    }
}
