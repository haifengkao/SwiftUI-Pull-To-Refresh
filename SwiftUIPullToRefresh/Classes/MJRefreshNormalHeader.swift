//
//  MJRefreshNormalHeader.swift
//  SwiftUIPullToRefresh
//
//  Created by Hai Feng Kao on 2021/6/6.
//

import SwiftUI

public struct MJRefreshNormalHeader: View {
    let refreshing: Bool
    @Binding var lastUpdatedTime: Date?

    let progress: Double
    public init(refreshing: Bool, lastUpdatedTime: Binding<Date?>, progress: Double) {
        self.refreshing = refreshing
        self.progress = progress
        _lastUpdatedTime = lastUpdatedTime
    }

    var title: Text {
        if refreshing {
            return Text("MJRefreshHeaderRefreshingText", bundle: BundleToken.bundle)
        }

        if progress > 1.0 {
            return Text("MJRefreshHeaderPullingText", bundle: BundleToken.bundle)
        } else {
            return Text("MJRefreshHeaderIdleText", bundle: BundleToken.bundle)
        }
    }

    var subtitle: Text {
        return Text("MJRefreshHeaderLastTimeText", bundle: BundleToken.bundle)
    }

    var lastUpdateText: Text {
        var isToday = false
        if let lastUpdatedTime = lastUpdatedTime {
            let formatter = DateFormatter()
            let currentDate = Date()
            if currentDate.get(.day) == lastUpdatedTime.get(.day) { // 今天
                isToday = true
                formatter.dateFormat = "HH:mm"
            } else if currentDate.get(.year) == lastUpdatedTime.get(.year) { // 今年
                formatter.dateFormat = "MM-dd HH:mm"
            } else {
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
            }

            let localizedToday = isToday ? BundleToken.bundle.localizedString(forKey: "MJRefreshHeaderDateTodayText", value: nil, table: nil) : ""

            return Text("\(localizedToday) \(formatter.string(from: lastUpdatedTime))")

        } else {
            return Text("MJRefreshHeaderNoneLastDateText", bundle: BundleToken.bundle)
        }
    }

    public var body: some View {
        ZStack {
            // Color.green // debug only

            HStack {
                if refreshing {
                    ActivityIndicator(style: .medium)
                } else {
                    Image("arrow", bundle: BundleToken.bundle)
                        .rotationEffect(.degrees(progress > 1.0 ? 180 : 0))
                        .animation(.linear, value: progress)
                }

                VStack {
                    title

                    HStack(alignment: .center, spacing: 0.0) {
                        subtitle
                        lastUpdateText
                    }

                }.font(.bold(.system(size: 14.0))())
                    .foregroundColor(.MJRefreshLabelTextColor)
                    .background(Color.clear)

            }.onChange(of: refreshing, perform: { newValue in

                if !newValue {
                    self.lastUpdatedTime = Date()
                }
            })
        }
    }
}
