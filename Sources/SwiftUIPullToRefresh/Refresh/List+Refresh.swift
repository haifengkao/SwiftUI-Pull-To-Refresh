//
//  List+Refresh.swift
//  Refresh
//
//  Created by Gesen on 2020/3/7.
//  https://github.com/wxxsw/Refresh

import SwiftUI

#if os(iOS)
    @available(iOS 13.0, *)
    public extension ScrollView {
        func enableRefresh(_ enable: Bool = true) -> some View {
            modifier(Refresh.Modifier(enable: enable))
        }
    }
#endif
