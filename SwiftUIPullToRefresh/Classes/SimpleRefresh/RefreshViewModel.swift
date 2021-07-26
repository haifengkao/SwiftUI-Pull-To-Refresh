//
//  RefreshViewModel.swift
//  SwiftUIPullToRefresh
//
//  Created by Hai Feng Kao on 2021/7/26.
//

import SwiftUI

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
        case let .updateRefreshHeaderAction(action):
            reduce(action, state: &newState)
        case let .updateRefreshHeader(bounds):
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
