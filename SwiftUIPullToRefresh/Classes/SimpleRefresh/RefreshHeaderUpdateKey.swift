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
    var headerUpdate: RefreshHeaderUpdateKey.Value {
        get { self[RefreshHeaderUpdateKey.self] }
        set { self[RefreshHeaderUpdateKey.self] = newValue }
    }
}

enum RefreshHeaderUpdateKey {
    static var defaultValue: Value = .empty
}

@available(iOS 13.0, *)
extension RefreshHeaderUpdateKey: EnvironmentKey {
    typealias Value = RefreshViewState
}
