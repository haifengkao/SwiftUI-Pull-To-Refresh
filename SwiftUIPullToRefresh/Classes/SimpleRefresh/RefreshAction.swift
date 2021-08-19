//
//  RefreshAction.swift
//  SwiftUIPullToRefresh
//
//  Created by Hai Feng Kao on 2021/7/26.
//

import Foundation

// sourcery: Prism
enum RefreshAction {
    case updateScrollViewState(ScrollViewState)
    case updateMinListRowHeight(CGFloat)
    case updateRefreshHeader(CGRect)
    case updateRefreshHeaderAction(Action)
    case endRefresh
    case endAnimating

    case callRefreshOnInit(Action)
}
