//
//  Utilities.swift
//  Demo
//
//  Created by Gesen on 2020/3/22.
//  https://github.com/wxxsw/Refresh

import SwiftUI

@available(iOS 13.0, *)
extension View {
    @ViewBuilder func clipped(_ value: Bool) -> some View {
        if value {
            clipped()
        } else {
            self
        }
    }
}

@available(iOS 13.0, *)
extension EdgeInsets {
    static var zero: EdgeInsets {
        .init(top: 0, leading: 0, bottom: 0, trailing: 0)
    }
}
