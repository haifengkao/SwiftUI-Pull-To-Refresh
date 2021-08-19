//
//  AutoRefreshDemoView.swift
//  AutoRefreshDemoView
//
//  Created by Hai Feng Kao on 2021/8/18.
//

import SwiftUI
import SwiftUIPullToRefresh

struct AutoRefreshDemoView: View {
    typealias Item = WXXSWRefreshDemoView.Item
    @State private var items: [Item] = []

    @State private var headerLastUpdatedTime: Date? = nil
    @State private var footerRefreshing: Bool = false
    @State private var noMore: Bool = false

    var body: some View {
        ScrollView {
            // if items.count > 0 {
            RefreshHeader { update in

                MJRefreshNormalHeader(refreshing: update.refreshing, lastUpdatedTime: $headerLastUpdatedTime, progress: Double(update.progress))
                // .opacity(Double(min(update.progress, 1.0)))
                // SimplePullToRefreshView(progress: progress)
            }
            // }

            ForEach(items) { item in
                SimpleCell(item: item)
            }
        }
        .headerRefreshable(autoRefreshOnInit: true) { endRefresh in
            self.reload(endRefresh: endRefresh)
        }
        .navigationBarBackground {
            Color.pink.shadow(radius: 1) // don't forget the shadow under the opaque navigation bar
        }
    }

    func reload(endRefresh: @escaping EndRefresh) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.items = WXXSWRefreshDemoView.generateItems(count: 20)
            self.noMore = false
            endRefresh()
        }
    }

    func loadMore() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.items += WXXSWRefreshDemoView.generateItems(count: 10)
            self.footerRefreshing = false
            self.noMore = self.items.count > 50
        }
    }
}
