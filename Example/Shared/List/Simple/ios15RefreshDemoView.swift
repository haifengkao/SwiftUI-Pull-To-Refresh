//
//  ios15RefreshDemoView.swift
//  SwiftUIPullToRefresh
//
//  Created by Hai Feng Kao on 2021/8/18.
//

import SwiftUI

@available(iOS 15, *)
struct ios15RefreshDemoView: View {
    typealias Item = WXXSWRefreshDemoView.Item

    @State private var items: [Item] = WXXSWRefreshDemoView.generateItems(count: 20)

    var body: some View {
        List {
            ForEach(items) { item in
                SimpleCell(item: item)
            }
        }
        .refreshable {
            // Nothing to execute
            self.items = try! await getItems().get()
        }.navigationBarBackground {
            Color.blue.shadow(radius: 1) // don't forget the shadow under the opaque navigation bar
        }
    }

    func getItems() async -> Result<[Item], Error> {
        await withUnsafeContinuation { c in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                c.resume(returning: .success(WXXSWRefreshDemoView.generateItems(count: 20)))
            }
        }
    }
}
