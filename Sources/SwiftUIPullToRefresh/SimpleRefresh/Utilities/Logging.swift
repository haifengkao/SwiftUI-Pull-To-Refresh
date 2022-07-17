//
//  Logging.swift
//  SwiftUIPullToRefresh
//
//  Created by Hai Feng Kao on 2022/7/17.
//

import Foundation
import os

var logger: Logger {
    SwiftUIPullToRefresh.logger
}

enum SwiftUIPullToRefresh {
    static let subsystem = "com.logging.SwiftUIPullToRefresh"
    static let category = "UI"
    static let osLog: OSLog = {
        #if DEBUG
            OSLog(subsystem: subsystem, category: category)
        #else
            OSLog.disabled // disable logging at release mode
        #endif
    }()

    /// to disable debug mode logging, set SwiftUIPullToRefresh.loggger = .init(OSLog.disabled)
    static var logger: Logger = .init(osLog)
}
