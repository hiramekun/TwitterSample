//
// Created by Takaaki Hirano on 2017/05/13.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class TimelineViewController: UIViewController {
    
    // MARK: - Properties -
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate let timelineViewModelType: TimelineViewModelType
    
    
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
        timelineViewModelType = viewModel
        
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
        setupBinding()
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
    
    fileprivate func setupBinding() {
        postButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.pushViewController(CreateTweetViewController(),
                                                               animated: true)
            })
            .disposed(by: disposeBag)
        
        timelineViewModelType.outputs.tweets
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
