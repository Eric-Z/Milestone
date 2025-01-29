//
//  Item.swift
//  Milestone
//
//  Created by 庄慧 on 2025/1/29.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
