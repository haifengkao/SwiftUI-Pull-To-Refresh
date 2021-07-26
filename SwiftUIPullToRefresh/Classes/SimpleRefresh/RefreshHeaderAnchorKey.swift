//
//  RefreshHeaderAnchorKey.swift
//  SwiftUIPullToRefresh
//
//  Created by Hai Feng Kao on 2021/7/26.
//

import SwiftUI


@available(iOS 13.0, *)
enum RefreshHeaderAnchorKey: PreferenceKey {
    static var defaultValue: Value = []

    typealias Value = [Item]

    struct Item {
        let bounds: Anchor<CGRect>
    }

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}
