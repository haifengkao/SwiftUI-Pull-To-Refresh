//
//  RefreshState.swift
//  SwiftUIPullToRefresh
//
//  Created by Hai Feng Kao on 2021/7/26.
//

import CoreGraphics
import Foundation

/// the real(internal) state of the pull to refresh view
struct PullToRefreshState: CustomStringConvertible {
    var description: String {
        "RefreshState(status: \(status), scrollViewState: \(scrollViewState), headerBounds: \(headerBounds), minListRowHeight: \(minListRowHeight)), progress: \(headerProgress)"
    }

    var refreshOnInitExecuted: Bool = false
    var isAnimating: Bool = false
    var status: MJRefreshState = .idle
    var scrollViewState: ScrollViewState = .empty
    var endRefresh: EndRefresh = {}
    var onReload: Action = { _ in }
    var headerBounds: CGRect = .zero
    var headerProgress: CGFloat { max(0, headerBounds.maxY / headerBounds.height) }

    var paddingToHideHeader: CGFloat {
        return -max(minListRowHeight, headerBounds.height)
    }

    var minListRowHeight: CGFloat = 0.0 // to support List
    static let empty: PullToRefreshState = .init()

    var canRefresh: Bool {
        status == .willRefresh && headerProgress < 1.0 // to avoid headerView position changes drastically, delay the refresh until scrollView bounces to contentOffset ~ 0.0
    }

    mutating func beginRefresh(onReload: Action? = nil) {
        // handle end refresh
        status = .refresh

        let onReload = (onReload != nil) ? onReload! : self.onReload
        onReload(endRefresh)
    }
}

extension PullToRefreshState {
    /// returns the public interface of the internal state
    var asViewState: PullToRefreshViewState {
        PullToRefreshViewState(
            shouldAnimating: status == .endingRefresh,
            paddingToHideHeader: paddingToHideHeader,
            refreshing: status == .refresh,
            progress: headerProgress
        )
    }

    var canEndAnimation: Bool {
        status == .endingRefresh
    }
}
