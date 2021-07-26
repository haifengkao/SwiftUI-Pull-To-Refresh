//
//  RefreshModifier.swift
//  SwiftUIPullToRefresh
//
//  Created by Hai Feng Kao on 2021/7/24.
//  Copyright (c) 2021 Hai Feng Kao. All rights reserved.
//

import Introspect
import SwiftUI


@available(iOS 13.0, *)
struct RefreshModifier {
    let headerAction: Action

    @StateObject var viewModel: RefreshViewModel = .init()

    init(headerAction: @escaping Action) {
        self.headerAction = headerAction
    }

    @Environment(\.defaultMinListRowHeight) var rowHeight
}

@available(iOS 13.0, *)
extension RefreshModifier: ViewModifier {
    
    var state: RefreshViewState {
        viewModel.viewState
    }

    func dispatch(_ action: RefreshAction) {
        viewModel.dispatch(action)
    }

    func body(content: Content) -> some View {
        return GeometryReader { proxy in

            content
                .environment(\.headerUpdate, state)
                .padding(.top, state.headerPadding)
                // .clipped(true) // https://github.com/siteline/SwiftUI-Introspect/issues/115
                .onAnimationCompleted(for: state.headerPadding) {
                    dispatch(.endAnimating)
                    print("Intro text animated in!")
                }

                // .clipped(proxy.safeAreaInsets == .zero)
                .backgroundPreferenceValue(RefreshHeaderAnchorKey.self) { v -> Color in
                    DispatchQueue.main.async { self.update(proxy: proxy, value: v) }
                    return Color.clear
                }

        }.introspectScrollView { scrollView in
            self.viewModel.scrollView = scrollView
            dispatch(.updateRefreshHeaderAction(headerAction))
        }
    }

    func update(proxy: GeometryProxy, value: RefreshHeaderAnchorKey.Value) {
        guard let value = value.last else {
            return
        }

        var bound: CGRect = proxy[value.bounds]
        // bound.origin = .zero // avoid infinite loop
        dispatch(.updateRefreshHeader(bound))
    }
}

@available(iOS 13.0, *)
public extension ScrollView {
    func headerRefreshable(_ headerAction: @escaping Action) -> some View {
        modifier(RefreshModifier(headerAction: headerAction))
    }
}

func reduce(_ action: @escaping Action, state: inout RefreshState) {
    state.onReload = action
}

func reduce(headerBounds: CGRect, state: inout RefreshState) {
    state.headerBounds = headerBounds
}

func reduce(_ newScrollViewState: ScrollViewState, state: inout RefreshState) {
    // print("newScroll", newScrollViewState)
    // let oldScrollViewState = state.scrollViewState
    state.scrollViewState = newScrollViewState

    let newProgress = state.headerProgress
    switch state.status {
    case .idle:
        if newScrollViewState.isTracking, newProgress >= 1.0 {
            state.status = .pulling
        }
    case .pulling:
        if newScrollViewState.isTracking, newProgress < 1.0 {
            state.status = .idle
        }

        if !newScrollViewState.isTracking {
            state.status = .willRefresh
        }

    case .willRefresh:
        if newScrollViewState.isTracking {
            // user touch will stop the refresh
            if newProgress >= 1.0 {
                state.status = .pulling
            } else {
                state.status = .idle
            }
        } else {
            if state.canRefresh {
                print("begin refresh")
                state.beginRefresh()
            }
        }
    case .endingRefresh:
        break // just waiting

    case .noMoreData:
        break // only footer needs it

    case .refresh:
        break // just waiting
    }
}
