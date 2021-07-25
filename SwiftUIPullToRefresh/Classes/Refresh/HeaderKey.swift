//
//  HeaderKey.swift
//  Refresh
//
//  Created by Gesen on 2020/3/22.
//  https://github.com/wxxsw/Refresh

import SwiftUI

@available(iOS 13.0, *)
extension EnvironmentValues {
    var refreshHeaderUpdate: Refresh.HeaderUpdateKey.Value {
        get { self[Refresh.HeaderUpdateKey.self] }
        set { self[Refresh.HeaderUpdateKey.self] = newValue }
    }
}

@available(iOS 13.0, *)
extension Refresh {
    enum HeaderAnchorKey {
        static var defaultValue: Value = []
    }

    enum HeaderUpdateKey {
        static var defaultValue: Value = .init(enable: false)
    }
}

@available(iOS 13.0, *)
extension Refresh.HeaderAnchorKey: PreferenceKey {
    typealias Value = [Item]

    struct Item {
        let bounds: Anchor<CGRect>
        let refreshing: Bool
    }

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}

let historyCount = 3
@available(iOS 13.0, *)
extension Refresh.HeaderUpdateKey: EnvironmentKey {
    struct Value {
        let enable: Bool
        var progress: CGFloat = 0
        var refresh: Bool = false
        var animating: Bool = false // true if the header is moving out of screen

        var states: [MJRefreshState] = [.idle]
        var currentTracking: Bool = false
        var currentRefreshing: Bool = false // true if client is refreshing the data

        var currentState: MJRefreshState { states.last! }
        var previousState: MJRefreshState? {
            if states.count < 2 { return nil }
            return states[states.count - 2]
        }

        var canRefresh: Bool {
            if let prevState = previousState,
               currentState == .willRefresh,
               prevState != currentState
            {
                return true
            }

            return false
        }

        // return true if the value has been updated
        mutating func update(isRefreshing: Bool) -> Bool {
            if isRefreshing == currentRefreshing { return false }
            currentRefreshing = isRefreshing

            if isRefreshing {
                onRefresh()
            } else {
                onRefreshEnd()
            }
            return true
        }

        mutating func update(tracking: Bool) {
            if tracking {
                onDragChange()
            }
            if tracking != currentTracking {
                currentTracking = tracking

                if !tracking {
                    onDragEnd()
                }
            }
        }

        mutating func updateState(state: MJRefreshState) {
            if state != currentState {
                states.append(state)
                states = states.suffix(historyCount)
            }
        }

        mutating func onDragChange() {
            if currentState == .pulling, progress < 1.0 {
                updateState(state: .idle)
            }

            if currentState == .idle, progress >= 1.0 {
                updateState(state: .pulling)
            }
        }

        mutating func onDragEnd() {
            if currentState == .pulling {
                updateState(state: .willRefresh)
            }
        }

        mutating func onRefresh() {
            assert(currentState == .willRefresh)
            updateState(state: .refresh)
        }

        mutating func onRefreshEnd() {
            assert(currentState == .refresh)
            updateState(state: .idle)
        }
    }
}
