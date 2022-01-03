//
//  SingleListInNavigtionView.swift
//  Demo
//
//  Created by Gesen on 2020/3/22.
//

import SwiftUI
import SwiftUINavigationBarColor

struct SingleListInNavigtionView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: WXXSWRefreshDemoView(), label: {
                    Text("WXXSW/Refresh")
                })
                Divider()
                NavigationLink(destination: ManualRefreshDemoView(), label: {
                    Text("SwiftUIPullToRefresh manual")
                })
                Divider()
                NavigationLink(destination: AutoRefreshDemoView(), label: {
                    Text("SwiftUIPullToRefresh refresh on start")
                })
                Divider()
                if #available(iOS 15, *) {
                    NavigationLink(destination: ios15RefreshDemoView(), label: {
                        Text("iOS 15 native pull to refresh")
                    })
                } else {
                    // Fallback on earlier versions
                }
            }
            .navigationBarBackground {
                Color.pink.shadow(radius: 1) // don't forget the shadow under the opaque navigation bar
            }
            .navigationTransparentBar(tintColor: .white)
            .navigationViewStyle(StackNavigationViewStyle())

            .navigationBarTitle("Single List in NavigationView", displayMode: .inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SingleListInNavigtionView()
    }
}
