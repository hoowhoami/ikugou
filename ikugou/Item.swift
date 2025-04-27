//
//  Item.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/4/27.
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
