//
//  ikugouApp.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/4.
//

import SwiftUI

@main
struct ikugouApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
