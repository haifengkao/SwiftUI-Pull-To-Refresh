//
//  ScrollViewState.swift
//  SwiftUIPullToRefresh
//
//  Created by Hai Feng Kao on 2021/7/25.
//

import CoreGraphics
import Foundation
struct ScrollViewState: Equatable {
    let contentOffset: CGPoint
    let contentSize: CGSize
    let isTracking: Bool

    static let empty: ScrollViewState = .init(contentOffset: .zero, contentSize: .zero, isTracking: false)
}
