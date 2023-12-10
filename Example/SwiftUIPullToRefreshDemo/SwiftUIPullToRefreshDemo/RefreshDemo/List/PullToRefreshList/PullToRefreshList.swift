//
//  File.swift
//
//
//  Created by Hai Feng Kao on 2023/12/8.
//

import SwiftUI
import SwiftUIPullToRefresh
struct PullToRefreshList: View {
    @State private var headerLastUpdatedTime: Date? = nil
    @State private var items: [Item] = []
    @State private var headerRefreshing: Bool = false
    @State private var footerRefreshing: Bool = false
    @State private var noMore: Bool = false

    var body: some View {
        ScrollView {
            if items.count > 0 {
                PullToRefreshHeader { update in

                    MJRefreshNormalHeader(refreshing: update.refreshing, lastUpdatedTime: $headerLastUpdatedTime, progress: Double(update.progress))
                        //.opacity(Double(min(update.progress, 1.0)))
                    // SimplePullToRefreshView(progress: progress)
                }
            }

            ForEach(items) { item in
                SimpleCell(item: item)
            }
        }
        .headerRefreshable { endRefresh in
            self.reload(endRefresh: endRefresh)
        }

        .overlay(Group {
            if items.count == 0 {
                ActivityIndicator(style: .medium)
            } else {
                EmptyView()
            }
        })
        .onAppear { self.items = SimpleList.generateItems(count: 5) }
    }

    func reload(endRefresh: @escaping EndRefresh = {}) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            
            self.items = SimpleList.generateItems(count: 5)
            self.noMore = false
            endRefresh()
        }
    }

    func loadMore() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.items += SimpleList.generateItems(count: 10)
            self.footerRefreshing = false
            self.noMore = self.items.count > 50
        }
    }
}
