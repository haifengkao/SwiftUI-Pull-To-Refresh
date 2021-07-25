//
//  ActivityIndicator.swift
//  Demo
//
//  Created by Gesen on 2020/3/22.
//

import SwiftUI

struct ActivityIndicator: UIViewRepresentable {
    let style: UIActivityIndicatorView.Style

    func makeUIView(context _: Context) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context _: Context) {
        uiView.startAnimating()
    }
}
