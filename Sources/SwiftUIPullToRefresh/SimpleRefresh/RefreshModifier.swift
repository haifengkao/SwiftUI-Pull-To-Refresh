//
//  RefreshModifier.swift
//  SwiftUIPullToRefresh
//
//  Created by Hai Feng Kao on 2021/7/24.
//  Copyright (c) 2021 Hai Feng Kao. All rights reserved.
//

import Introspect
import SwiftUI

#if os(iOS)
    @available(iOS 13.0, *)
    struct RefreshModifier {
        var shouldRefreshOnInit: Bool = false
        let headerAction: Action

        @StateObject var viewModel: RefreshViewModel = .init()

        init(autoRefreshOnInit: Bool, headerAction: @escaping Action) {
            shouldRefreshOnInit = autoRefreshOnInit
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
                if self.shouldRefreshOnInit {
                    dispatch(.callRefreshOnInit(headerAction))
                }
            }
        }

        func update(proxy: GeometryProxy, value: RefreshHeaderAnchorKey.Value) {
            guard let value = value.last else {
                return
            }

            let bound: CGRect = proxy[value.bounds]
            // bound.origin = .zero // avoid infinite loop
            dispatch(.updateRefreshHeader(bound))
        }
    }

    @available(iOS 13.0, *)
    public extension ScrollView {
        func headerRefreshable(autoRefreshOnInit: Bool = false, _ headerAction: @escaping Action) -> some View {
            modifier(RefreshModifier(autoRefreshOnInit: autoRefreshOnInit, headerAction: headerAction))
        }
    }

#endif
