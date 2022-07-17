//
//  RefreshViewState.swift
//  SwiftUIPullToRefresh
//
//  Created by Hai Feng Kao on 2021/7/26.
//

import CoreGraphics
import Foundation
public struct RefreshViewState: Equatable {
    var headerPadding: CGFloat = 0.0
    var shouldAnimating: Bool = false // the header view moving down doesn't need animation, otherwsie the layout would be incorrect, but moving up needs animation
    public var refreshing: Bool = false
    public var progress: CGFloat = 0.0
    static let empty: Self = .init()
}

extension RefreshViewState: CustomStringConvertible {
    public var description: String {
        "RefreshViewState(headerPadding: \(headerPadding), shouldAnimating: \(shouldAnimating), refreshing: \(refreshing), progress: \(progress))"
    }
}
