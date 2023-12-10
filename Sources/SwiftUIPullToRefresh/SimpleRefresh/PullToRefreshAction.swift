//
//  RefreshAction.swift
//  SwiftUIPullToRefresh
//
//  Created by Hai Feng Kao on 2021/7/26.
//

import CoreGraphics
import Foundation
// sourcery: Prism
enum PullToRefreshAction {
    case updateScrollViewState(ScrollViewState)
    case updateMinListRowHeight(CGFloat)
    case updateRefreshHeader(CGRect)
    case updateRefreshHeaderAction(Action)

    /// when the reload action has finished, call this to end the refresh
    /// it will trigger the header view bounces out of the view animation
    case endRefresh

    /// when the header view bounces out animation has finished
    /// call this to set the status to idle
    case endAnimating

    /// if you want to refresh on init, call this action
    case callRefreshOnInit(Action)
}
