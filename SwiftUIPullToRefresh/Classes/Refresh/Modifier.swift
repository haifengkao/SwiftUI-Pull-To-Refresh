//
//  Modifier.swift
//  Refresh
//
//  Created by Gesen on 2020/3/8.
//  https://github.com/wxxsw/Refresh

import Introspect
import SwiftUI
@available(iOS 13.0, *)
extension Refresh {
    struct Modifier {
        let isEnabled: Bool

        @State private var id: Int = 0
        @State private var headerUpdate: HeaderUpdateKey.Value
        @State private var headerPadding: CGFloat = 0

        @State private var footerUpdate: FooterUpdateKey.Value
        @State private var footerPreviousRefreshAt: Date?

        @GestureState private var dragOffset: CGSize = .zero
        init(enable: Bool) {
            isEnabled = enable
            _headerUpdate = State(initialValue: .init(enable: enable))
            _footerUpdate = State(initialValue: .init(enable: enable))
        }

        @Environment(\.defaultMinListRowHeight) var rowHeight
    }
}

@available(iOS 13.0, *)
extension Refresh.Modifier: ViewModifier {
    func body(content: Content) -> some View {
        return GeometryReader { proxy in

            content
                .environment(\.refreshHeaderUpdate, self.headerUpdate)
                .environment(\.refreshFooterUpdate, self.footerUpdate)
                .padding(.top, headerPadding)
                .clipped(proxy.safeAreaInsets == .zero)
                .backgroundPreferenceValue(Refresh.HeaderAnchorKey.self) { v -> Color in
                    DispatchQueue.main.async { self.update(proxy: proxy, value: v) }
                    return Color.clear
                }
                .backgroundPreferenceValue(Refresh.FooterAnchorKey.self) { v -> Color in
                    DispatchQueue.main.async { self.update(proxy: proxy, value: v) }
                    return Color.clear
                }
                .id(self.id)
        }.introspectScrollView { scrollView in
            self.headerUpdate.update(tracking: scrollView.isTracking)
        }
    }

    func update(proxy: GeometryProxy, value: Refresh.HeaderAnchorKey.Value) {
        guard let item = value.first else { return }
        guard !footerUpdate.refresh else { return }

        let bounds = proxy[item.bounds]
        var update = headerUpdate

        if update.animating { return }

        update.progress = max(0, bounds.maxY / bounds.height)
        let changed = update.update(isRefreshing: item.refreshing)
        if changed, !item.refreshing {
            id += 1 // what's id?
        }

        let toBeUpdatedPadding = headerUpdate.currentRefreshing ? 0 : -max(rowHeight, bounds.height)
        let duration = 0.3

        if headerPadding > toBeUpdatedPadding {
            // moving up animation after refresh
            update.animating = true
            withAnimation(.linear(duration: duration)) {
                headerPadding = toBeUpdatedPadding
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.headerUpdate.animating = false
            }
        } else {
            // moving up and then stick the refresh header view on the top
            // this part is not animated because the scrollView's bouncing-back animation
            // will conflict with padding update animation
            // TODO: we can workaround by set contentOffset of scrollView to be the current contentOffset
            // to stop the bouncing-back animation
            // or we can record the current contentOffset of scorllView, and set the padding when the
            // the header view is closed to the desired location
            headerPadding = toBeUpdatedPadding
        }
        headerUpdate = update
    }

    func update(proxy: GeometryProxy, value: Refresh.FooterAnchorKey.Value) {
        guard let item = value.first else { return }
        guard headerUpdate.progress == 0 else { return }

        let bounds = proxy[item.bounds]
        var update = footerUpdate

        if bounds.minY <= rowHeight || bounds.minY <= bounds.height {
            update.refresh = false
        } else if update.refresh, !item.refreshing {
            update.refresh = false
        } else {
            update.refresh = proxy.size.height - bounds.minY + item.preloadOffset > 0
        }

        if update.refresh, !footerUpdate.refresh {
            if let date = footerPreviousRefreshAt, Date().timeIntervalSince(date) < 0.1 {
                update.refresh = false
            }
            footerPreviousRefreshAt = Date()
        }

        footerUpdate = update
    }
}

/// An animatable modifier that is used for observing animations for a given animatable value.
struct AnimationCompletionObserverModifier<Value>: AnimatableModifier where Value: VectorArithmetic {
    /// While animating, SwiftUI changes the old input value to the new target value using this property. This value is set to the old value until the animation completes.
    var animatableData: Value {
        didSet {
            notifyCompletionIfFinished()
        }
    }

    /// The target value for which we're observing. This value is directly set once the animation starts. During animation, `animatableData` will hold the oldValue and is only updated to the target value once the animation completes.
    private var targetValue: Value

    /// The completion callback which is called once the animation completes.
    private var completion: () -> Void

    init(observedValue: Value, completion: @escaping () -> Void) {
        self.completion = completion
        animatableData = observedValue
        targetValue = observedValue
    }

    /// Verifies whether the current animation is finished and calls the completion callback if true.
    private func notifyCompletionIfFinished() {
        guard animatableData == targetValue else { return }

        /// Dispatching is needed to take the next runloop for the completion callback.
        /// This prevents errors like "Modifying state during view update, this will cause undefined behavior."
        DispatchQueue.main.async {
            self.completion()
        }
    }

    func body(content: Content) -> some View {
        /// We're not really modifying the view so we can directly return the original input value.
        return content
    }
}

extension View {
    /// Calls the completion handler whenever an animation on the given value completes.
    /// - Parameters:
    ///   - value: The value to observe for animations.
    ///   - completion: The completion callback to call once the animation completes.
    /// - Returns: A modified `View` instance with the observer attached.
    func onAnimationCompleted<Value: VectorArithmetic>(for value: Value, completion: @escaping () -> Void) -> ModifiedContent<Self, AnimationCompletionObserverModifier<Value>> {
        return modifier(AnimationCompletionObserverModifier(observedValue: value, completion: completion))
    }
}
