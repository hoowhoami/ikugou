//
//  DateUtils.swift
//  ikugou
//
//  Created by 蒋梁通 on 2025/8/4.
//

import Foundation

struct DateUtils {
    /// 格式化日期为字符串
    static func formatDate(_ date: Date, format: String = "yyyy-MM-dd HH:mm") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
