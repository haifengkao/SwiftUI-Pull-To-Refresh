//
//  Modifier.swift
//  Refresh
//
//  Created by Gesen on 2020/3/8.
//  https://github.com/wxxsw/Refresh

import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect
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

#if os(iOS)
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
            }
            .introspect(.scrollView, on: .iOS(.v13...), scope: .ancestor) { scrollView in
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

#endif
