//
//  ContentArea.swift
//  ikugou
//
//  Created on 2025/8/4.
//

import SwiftUI

struct ContentArea: View {
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
    ContentArea(selectedItem: .home)
}
