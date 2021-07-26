//
//  RefreshState.swift
//  SwiftUIPullToRefresh
//
//  Created by Hai Feng Kao on 2021/7/26.
//

import Foundation


struct RefreshState: CustomStringConvertible {
    var description: String {
        "RefreshState(status: \(status), scrollViewState: \(scrollViewState), headerBounds: \(headerBounds), minListRowHeight: \(minListRowHeight)), progress: \(headerProgress), padding: \(headerPadding)"
    }

    var isAnimating: Bool = false
    var status: MJRefreshState = .idle
    var scrollViewState: ScrollViewState = .empty
    var endRefresh: EndRefresh = {}
    var onReload: Action = { _ in }
    var headerBounds: CGRect = .zero
    var headerProgress: CGFloat { max(0, headerBounds.maxY / headerBounds.height) }
    var headerPadding: CGFloat {
        status == .refresh ? 0.0 : -max(minListRowHeight, headerBounds.height)
    }

    var minListRowHeight: CGFloat = 0.0 // to support List
    static let empty: RefreshState = .init()

    var canRefresh: Bool {
        status == .willRefresh && headerProgress < 1.0 // to avoid headerView position changes drastically, delay the refresh until scrollView bounces to contentOffset ~ 0.0
    }

    mutating func beginRefresh() {
        // handle end refresh
        status = .refresh
        onReload(endRefresh)
    }
}

extension RefreshState {
    var asViewState: RefreshViewState {
        .init(headerPadding: headerPadding, shouldAnimating: status == .endingRefresh, refreshing: status == .refresh, progress:headerProgress)
    }
}
