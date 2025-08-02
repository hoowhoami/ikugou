//
//  ColorExtensions.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/2.
//

import SwiftUI
import AppKit

// 为NSColor添加Spotify风格颜色扩展
extension NSColor {
    static let spotifyBackground = NSColor(red: 24/255, green: 24/255, blue: 24/255, alpha: 1)
    static let spotifySidebar = NSColor(red: 15/255, green: 15/255, blue: 15/255, alpha: 1)
    static let spotifyPlayback = NSColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
    static let spotifyCard = NSColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1)
    static let spotifyGreen = NSColor(red: 30/255, green: 215/255, blue: 96/255, alpha: 1)
    static let spotifyTextSecondary = NSColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)
    static let spotifyDivider = NSColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1)
}

// 为SwiftUI的Color添加对应的扩展
extension Color {
    static let spotifyBackground = Color(nsColor: .spotifyBackground)
    static let spotifySidebar = Color(nsColor: .spotifySidebar)
    static let spotifyPlayback = Color(nsColor: .spotifyPlayback)
    static let spotifyCard = Color(nsColor: .spotifyCard)
    static let spotifyGreen = Color(nsColor: .spotifyGreen)
    static let spotifyTextSecondary = Color(nsColor: .spotifyTextSecondary)
    static let spotifyDivider = Color(nsColor: .spotifyDivider)
}
