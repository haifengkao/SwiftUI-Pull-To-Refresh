//
//  Logging.swift
//  SwiftUIPullToRefresh
//
//  Created by Hai Feng Kao on 2022/7/17.
//

import Foundation
import os

var logger: Logger {
    Logging.logger
}

public enum Logging {
    public static let subsystem = "com.logging.SwiftUIPullToRefresh"
    public static let category = "UI"

    private static let osLog: OSLog = {
        #if DEBUG
            OSLog(subsystem: subsystem, category: category)
        #else
            OSLog.disabled // disable logging at release mode
        #endif
    }()

    /// to disable debug mode logging, set Logging.loggger = .init(OSLog.disabled)
    public static var logger: Logger = .init(osLog)
}
