//
//  Reducer.swift
//  Reducer
//
//  Created by Hai Feng Kao on 2021/8/19.
//

import CoreGraphics
import Foundation

import os
func reduce(_ action: @escaping Action, state: inout RefreshState) {
    state.onReload = action
}

func reduce(headerBounds: CGRect, state: inout RefreshState) {
    state.headerBounds = headerBounds
}

func reduce(scrollViewState newScrollViewState: ScrollViewState, state: inout RefreshState) {
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
                logger.info("begin refresh")
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
