//
//  Extension.swift
//  SwiftUIPullToRefresh
//
//  Created by Hai Feng Kao on 2021/6/6.
//

import SwiftUI

final class BundleToken {
    static let bundle: Bundle = {
        let myBundle = Bundle(for: BundleToken.self)

        guard let resourceBundleURL = myBundle.url(
            forResource: "SwiftUIPullToRefresh", withExtension: "bundle"
        )
        else { fatalError("SwiftUIPullToRefresh.bundle not found!") }

        guard let resourceBundle = Bundle(url: resourceBundleURL)
        else { fatalError("Cannot access SwiftUIPullToRefresh.bundle!") }

        return resourceBundle
    }()
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

extension Color {
    static let MJRefreshLabelTextColor: Color = .init(red: 90 / 255.0, green: 90 / 255.0, blue: 90 / 255.0)
}

#if !os(macOS)
    struct ActivityIndicator: UIViewRepresentable {
        let style: UIActivityIndicatorView.Style

        func makeUIView(context _: Context) -> UIActivityIndicatorView {
            return UIActivityIndicatorView(style: style)
        }

        func updateUIView(_ uiView: UIActivityIndicatorView, context _: Context) {
            uiView.startAnimating()
        }
    }
#endif
