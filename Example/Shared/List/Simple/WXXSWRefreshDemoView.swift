//
//  SimpleList.swift
//  Demo
//
//  Created by Gesen on 2020/3/22.
//

import SwiftUI
import SwiftUIPullToRefresh

struct WXXSWRefreshDemoView: View {
    struct Item: Identifiable {
        let id = UUID()
        let color: Color
        let contentHeight: CGFloat
    }

    @State private var items: [Item] = []
    @State private var headerRefreshing: Bool = false
    @State private var headerLastUpdatedTime: Date? = nil
    @State private var footerRefreshing: Bool = false
    @State private var noMore: Bool = false

    var body: some View {
        ScrollView {
            if items.count > 0 {
                Refresh.Header(refreshing: $headerRefreshing, action: {
                    self.reload()
                }) { progress in

                    MJRefreshNormalHeader(refreshing: self.headerRefreshing, lastUpdatedTime: $headerLastUpdatedTime, progress: Double(progress))
                    // SimplePullToRefreshView(progress: progress)
                }
            }

            ForEach(items) { item in
                SimpleCell(item: item)
            }

            if items.count > 0 {
                RefreshFooter(refreshing: $footerRefreshing, action: {
                    self.loadMore()
                }) {
                    if self.noMore {
                        Text("No more data !")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        SimpleRefreshingView()
                            .padding()
                    }
                }
                .noMore(noMore)
                .preload(offset: 500)
            }
        }
        .enableRefresh()
        .overlay(Group {
            if items.count == 0 {
                ActivityIndicator(style: .medium)
            } else {
                EmptyView()
            }
        })
        .onAppear { self.reload() }
        .navigationBarBackground {
            Color.red.shadow(radius: 1) // don't forget the shadow under the opaque navigation bar
        }
    }

    func reload() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.items = WXXSWRefreshDemoView.generateItems(count: 20)
            self.headerRefreshing = false
            self.noMore = false
        }
    }

    func loadMore() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.items += WXXSWRefreshDemoView.generateItems(count: 10)
            self.footerRefreshing = false
            self.noMore = self.items.count > 50
        }
    }
}

extension WXXSWRefreshDemoView {
    static func generateItems(count: Int) -> [Item] {
        (0 ..< count).map { _ in
            Item(
                color: Color(
                    red: Double.random(in: 0 ..< 255) / 255,
                    green: Double.random(in: 0 ..< 255) / 255,
                    blue: Double.random(in: 0 ..< 255) / 255
                ),
                contentHeight: CGFloat.random(in: 100 ..< 200)
            )
        }
    }
}

struct SimpleRefreshingView: View {
    var body: some View {
        ActivityIndicator(style: .medium)
    }
}
