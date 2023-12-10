//
//  RefreshModifier.swift
//  SwiftUIPullToRefresh
//
//  Created by Hai Feng Kao on 2021/7/24.
//  Copyright (c) 2021 Hai Feng Kao. All rights reserved.
//

import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

#if os(iOS)
    @available(iOS 13.0, *)
    struct PullToRefreshModifier {
        var shouldRefreshOnInit: Bool = false
        let headerAction: Action

        @StateObject var viewModel: PullToRefreshViewModel = .init()

        init(autoRefreshOnInit: Bool, headerAction: @escaping Action) {
            shouldRefreshOnInit = autoRefreshOnInit
            self.headerAction = headerAction
        }

        @Environment(\.defaultMinListRowHeight) var rowHeight
    }

    @available(iOS 13.0, *)
    extension PullToRefreshModifier: ViewModifier {
        var state: PullToRefreshViewState {
            viewModel.viewState
        }

        func dispatch(_ action: PullToRefreshAction) {
            viewModel.dispatch(action)
        }

        func body(content: Content) -> some View {
            return GeometryReader { proxy in

                content
                    .environment(\.headerUpdate, state)
                    .padding(.top, state.currentHeaderPadding)
                    // .clipped(true) // https://github.com/siteline/SwiftUI-Introspect/issues/115
                    .onChange(of: state.currentHeaderPadding) { [oldPadding = state.currentHeaderPadding] newPadding in
                        if state.canEndAnimation(oldPadding: oldPadding, newPadding: newPadding) {
                            dispatch(.endAnimating)
                        }
                       
                    }
                    .backgroundPreferenceValue(PullToRefreshHeaderAnchorKey.self) { v -> Color in
                        DispatchQueue.main.async { self.update(proxy: proxy, value: v) }
                        return Color.clear
                    }

            }.introspect(.scrollView, on: .iOS(.v13...), scope: .receiver) { scrollView in

                self.viewModel.scrollView = scrollView
                dispatch(.updateRefreshHeaderAction(headerAction))
                if self.shouldRefreshOnInit {
                    dispatch(.callRefreshOnInit(headerAction))
                }
            }
        }

        func update(proxy: GeometryProxy, value: PullToRefreshHeaderAnchorKey.Value) {
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
            modifier(PullToRefreshModifier(autoRefreshOnInit: autoRefreshOnInit, headerAction: headerAction))
        }
    }

#endif
