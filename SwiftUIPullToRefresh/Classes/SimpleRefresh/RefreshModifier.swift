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
enum RefreshHeaderAnchorKey: PreferenceKey {
    static var defaultValue: Value = []

    typealias Value = [Item]

    struct Item {
        let bounds: Anchor<CGRect>
        let action: Action
    }

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}

struct RefreshViewState: Equatable {
    var headerPadding: CGFloat = 0.0
    var shouldAnimating: Bool = false // the header view moving down doesn't need animation, otherwsie the layout would be incorrect, but moving up needs animation
    static let empty: Self = .init()
}

struct RefreshState: CustomStringConvertible {
    var description: String {
        "RefreshState(status: \(status), scrollViewState: \(scrollViewState), headerBounds: \(headerBounds), minListRowHeight: \(minListRowHeight)), progress: \(headerProgress), padding: \(headerPadding)"
    }

    var isAnimating: Bool = false
    var status: MJRefreshState = .idle
    var scrollViewState: ScrollViewState = .empty
    var endRefresh: EndRefresh = {}
    var onReload: Action = { _ in }
    var headerBounds: CGRect = .zero
    var headerProgress: CGFloat { max(0, headerBounds.maxY / headerBounds.height) }
    var headerPadding: CGFloat {
        status == .refresh ? 0.0 : -max(minListRowHeight, headerBounds.height)
    }

    var minListRowHeight: CGFloat = 0.0 // to support List
    static let empty: RefreshState = .init()

    var canRefresh: Bool {
        status == .willRefresh && headerProgress < 1.0 // to avoid headerView position changes drastically, delay the refresh until scrollView bounces to contentOffset ~ 0.0
    }

    mutating func beginRefresh() {
        // handle end refresh
        status = .refresh
        onReload(endRefresh)
    }
}

extension RefreshState {
    var asViewState: RefreshViewState {
        .init(headerPadding: headerPadding, shouldAnimating: status == .endingRefresh)
    }
}

// sourcery: Prism
enum RefreshAction {
    case updateScrollViewState(ScrollViewState)
    case updateMinListRowHeight(CGFloat)
    case updateRefreshHeader(Action, CGRect)
    case endRefresh
    case endAnimating
}

class RefreshViewModel: ObservableObject {
    init() {
        internalState.endRefresh = { [weak self] in
            self?.dispatch(.endRefresh)
        }
    }

    func dispatch(_ action: RefreshAction) {
        var newState = internalState
        switch action {
        case let .updateMinListRowHeight(height):
            newState.minListRowHeight = height
        case let .updateRefreshHeader(action, bounds):
            reduce(action, state: &newState)
            reduce(headerBounds: bounds, state: &newState)
        case let .updateScrollViewState(scrollViewState):
            reduce(scrollViewState, state: &newState)
        case .endRefresh:
            assert(internalState.status == .refresh)
            newState.status = .endingRefresh
        case .endAnimating:
            assert(internalState.isAnimating, "should have animating before")
            newState.isAnimating = false

            if newState.status == .endingRefresh {
                newState.status = .idle
            }
        }

        print("newState", newState.status, action)

        let newViewState = newState.asViewState
        if !newState.isAnimating, newViewState != viewState {
            print("old", viewState, "->", newViewState)
            if newViewState.shouldAnimating {
                newState.isAnimating = true
                withAnimation(.linear(duration: 0.3)) {
                    viewState = newViewState
                }
            } else {
                viewState = newViewState
            }
        }
        internalState = newState
    }

    var internalState: RefreshState = .empty
    @Published var viewState: RefreshViewState = .empty
    var ob: NSKeyValueObservation?

    private weak var _scrollView: UIScrollView?
    var scrollView: UIScrollView? {
        get {
            _scrollView
        }
        set {
            _scrollView = newValue
            if let scrollView = newValue {
                ob = scrollView.observe(\.contentOffset, options: [.new, .old, .initial]) { [weak self, weak scrollView] _, change in
                    guard let scrollView = scrollView, let offset = change.newValue else { return }

                    if let old = change.oldValue, offset == old { return }

                    print("contentOffset", offset)
                    let size = scrollView.contentSize
                    let isTracking = scrollView.isTracking

                    let state = ScrollViewState(contentOffset: offset, contentSize: size, isTracking: isTracking)
                    self?.dispatch(.updateScrollViewState(state))
                }
            }
        }
    }
}

@available(iOS 13.0, *)
struct RefreshModifier {
    let isEnabled: Bool

    @StateObject var viewModel: RefreshViewModel = .init()

    init(enable: Bool) {
        isEnabled = enable
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
        }
    }

    func update(proxy: GeometryProxy, value: RefreshHeaderAnchorKey.Value) {
        guard let value = value.last else {
            return
        }

        var bound: CGRect = proxy[value.bounds]
        // bound.origin = .zero // avoid infinite loop
        dispatch(.updateRefreshHeader(value.action, bound))
    }
}

@available(iOS 13.0, *)
public extension ScrollView {
    func headerRefreshable(_ enable: Bool = true) -> some View {
        modifier(RefreshModifier(enable: enable))
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
