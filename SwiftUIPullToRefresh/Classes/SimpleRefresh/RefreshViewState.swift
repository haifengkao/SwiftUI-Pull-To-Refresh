//
//  RefreshViewState.swift
//  SwiftUIPullToRefresh
//
//  Created by Hai Feng Kao on 2021/7/26.
//

import Foundation


struct RefreshViewState: Equatable {
    var headerPadding: CGFloat = 0.0
    var shouldAnimating: Bool = false // the header view moving down doesn't need animation, otherwsie the layout would be incorrect, but moving up needs animation
    static let empty: Self = .init()
}