//
//  ContentView.swift
//  ikugou
//
//  Created on 2025/8/4.
//

import SwiftUI

struct ContentView: View {
    let selectedItem: NavigationItemType
    
    var body: some View {
        Group {
            switch selectedItem {
            case .home:
                HomeView()
            case .discover:
                DiscoverView()
            case .library:
                LibraryView()
            case .userProfile:
                UserProfileView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
    }
}

#Preview {
    ContentView(selectedItem: .home)
}
