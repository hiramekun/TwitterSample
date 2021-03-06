//
// Created by Takaaki Hirano on 2017/05/13.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import Foundation
import RealmSwift

final class User: Object {
    
    // MARK: - Properties -
    
    private (set) dynamic var id: String = NSUUID().uuidString
    dynamic var name = ""
    
    let tweets = List<Tweet>()
    
    
    // MARK: - Configurations -
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
