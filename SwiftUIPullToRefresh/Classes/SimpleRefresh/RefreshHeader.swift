//
//  RefreshHeader.swift
//  Pods
//
//  Created by Hai Feng Kao on 2021/7/24.
//  Copyright (c) 2021 Hai Feng Kao. All rights reserved.
//

import SwiftUI

public typealias EndRefresh = () -> Void
public typealias Action = (@escaping EndRefresh) -> Void

@available(iOS 13.0, *)
public struct RefreshHeader<Label>: View where Label: View {
    @Environment(\.headerUpdate) var update
    
    let label: (RefreshViewState) -> Label

    public init(@ViewBuilder label: @escaping (RefreshViewState) -> Label) {
        self.label = label
    }

    public var body: some View {
        return Group {
            VStack(alignment: .center, spacing: 0) {
                Spacer()
                label(update)
                // .opacity(opacity) // TODO: add to MJHeader instead
            }
            .frame(maxWidth: .infinity)
        }
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        .anchorPreference(key: RefreshHeaderAnchorKey.self, value: .bounds) {
            [.init(bounds: $0)]
        }
    }

    // var opacity: Double {
    //    return Double(min(update.progress, 1.0))
    // }
}
