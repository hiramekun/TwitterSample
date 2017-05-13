//
// Created by Takaaki Hirano on 2017/05/13.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import Foundation
import RealmSwift

final class Comment: Object {
    
    // MARK: - Properties -
    
    private (set) dynamic var id: String = NSUUID().uuidString
    dynamic var createdAt = Date()
    dynamic var content = ""
    dynamic var user: User?
    
    let tweets = LinkingObjects(fromType: Tweet.self, property: "comments")
    
    
    // MARK: - Configurations -
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
