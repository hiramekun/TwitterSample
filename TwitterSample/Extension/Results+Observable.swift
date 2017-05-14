//
// Created by Takaaki Hirano on 2017/05/14.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

enum RealmChange<T:RealmSwift.Object> {
    case initial(results: Results<T>)
    case insertions(rows: [Int])
    case modifications(rows: [Int])
    case deletions(rows: [Int])
}


extension Results {
    var rx_response: Observable<RealmChange<Element>> {
        return Observable.create { observer in
            
            let token = self.addNotificationBlock { change in
                switch change {
                case .initial(self):
                    observer.onNext(.initial(results: self))
                case .update(_, let deletions, let insertions, let modifications):
                    observer.onNext(.deletions(rows: deletions))
                    observer.onNext(.insertions(rows: insertions))
                    observer.onNext(.modifications(rows: modifications))
                case .error(let error):
                    observer.onError(error)
                default:
                    break
                }
            }
            
            return Disposables.create() {
                token.stop()
            }
        }
    }
}