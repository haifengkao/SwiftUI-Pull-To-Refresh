// Generated using Sourcery 1.0.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

extension PullToRefreshAction {
    var updateScrollViewState: ScrollViewState? {
        get {
            guard case let .updateScrollViewState(associatedValue0) = self else { return nil }
            return (associatedValue0)
        }
        set {
            guard case .updateScrollViewState = self, let newValue = newValue else { return }
            self = .updateScrollViewState(newValue)
        }
    }

    var isUpdateScrollViewState: Bool {
        updateScrollViewState != nil
    }

    var updateMinListRowHeight: CGFloat? {
        get {
            guard case let .updateMinListRowHeight(associatedValue0) = self else { return nil }
            return (associatedValue0)
        }
        set {
            guard case .updateMinListRowHeight = self, let newValue = newValue else { return }
            self = .updateMinListRowHeight(newValue)
        }
    }

    var isUpdateMinListRowHeight: Bool {
        updateMinListRowHeight != nil
    }
}
