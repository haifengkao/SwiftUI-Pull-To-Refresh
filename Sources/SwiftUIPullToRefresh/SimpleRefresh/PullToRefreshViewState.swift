//
//  RefreshViewState.swift
//  SwiftUIPullToRefresh
//
//  Created by Hai Feng Kao on 2021/7/26.
//

import CoreGraphics
import Foundation
public struct PullToRefreshViewState: Equatable {
    /// cannot be 0.0, otherwise the padding will be stuck to be paddingToHideHeader
    /// it seems that SwiftUI will not update the view if the padding is 0.0
    static let paddingToShowHeader: CGFloat = 1.0

    init(shouldAnimating: Bool, paddingToHideHeader: CGFloat, refreshing: Bool, progress: CGFloat) {
        self.shouldAnimating = shouldAnimating
        self.paddingToHideHeader = paddingToHideHeader
        self.refreshing = refreshing
        self.progress = progress
    }

    var currentHeaderPadding: CGFloat {
        return refreshing ? Self.paddingToShowHeader : paddingToHideHeader
    }

    /// the header view moving down doesn't need animation
    /// otherwise the layout would be incorrect, but moving up needs animation
    var shouldAnimating: Bool
    var paddingToHideHeader: CGFloat
    public var refreshing: Bool
    public var progress: CGFloat
    static let empty: Self = .init(shouldAnimating: false, paddingToHideHeader: 0.0, refreshing: false, progress: 0.0)
}

extension PullToRefreshViewState {
    func canEndAnimation(oldPadding: CGFloat, newPadding: CGFloat)-> Bool {
        shouldAnimating // true when the header view is moving up
                && oldPadding != newPadding // redundant condition
                && oldPadding == Self.paddingToShowHeader
                && newPadding == paddingToHideHeader // need to deal with float arithmetic? No
    }
}
extension PullToRefreshViewState: CustomStringConvertible {
    public var description: String {
        "RefreshViewState(headerPadding: \(currentHeaderPadding), shouldAnimating: \(shouldAnimating), refreshing: \(refreshing), progress: \(progress))"
    }
}
