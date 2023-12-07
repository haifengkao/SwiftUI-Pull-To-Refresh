//
//  RefreshHeaderUpdateKey.swift
//  SwiftUIPullToRefresh
//
//  Created by Hai Feng Kao on 2021/7/26.
//
//  RefreshModifier will send data to RefreshHeader by RefreshHeaderUpdateKey

import SwiftUI

@available(iOS 13.0, *)
extension EnvironmentValues {
    var headerUpdate: PullToRefreshHeaderUpdateKey.Value {
        get { self[PullToRefreshHeaderUpdateKey.self] }
        set { self[PullToRefreshHeaderUpdateKey.self] = newValue }
    }
}

enum PullToRefreshHeaderUpdateKey {
    static var defaultValue: Value = .empty
}

@available(iOS 13.0, *)
extension PullToRefreshHeaderUpdateKey: EnvironmentKey {
    typealias Value = PullToRefreshViewState
}
