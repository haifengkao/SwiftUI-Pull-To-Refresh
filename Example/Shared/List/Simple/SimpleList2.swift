//
//  SimpleList2.swift
//  SwiftUIPullToRefresh
//
//  Created by Hai Feng Kao on 2021/7/24.
//  Copyright (c) 2021 Hai Feng Kao. All rights reserved.
//

import SwiftUIPullToRefresh
import SwiftUI

struct SimpleList2: View {
    struct Item: Identifiable {
        let id = UUID()
        let color: Color
        let contentHeight: CGFloat
    }

    @State private var items: [SimpleList.Item] = []
    
    @State private var headerLastUpdatedTime: Date? = nil
    @State private var footerRefreshing: Bool = false
    @State private var noMore: Bool = false

    var body: some View {
        ScrollView {
            
            if items.count > 0 {
                RefreshHeader { update in

                    MJRefreshNormalHeader(refreshing: update.refreshing, lastUpdatedTime: $headerLastUpdatedTime, progress: Double(update.progress))
                        .opacity(Double(min(update.progress, 1.0)))
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
        .onAppear { self.reload() }
    }

    func reload(endRefresh: @escaping EndRefresh = { }) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.items = SimpleList.generateItems(count: 20)
            self.noMore = false
            endRefresh()
        }
    }

    func loadMore() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.items += SimpleList.generateItems(count: 10)
            self.footerRefreshing = false
            self.noMore = self.items.count > 50
        }
    }
}
