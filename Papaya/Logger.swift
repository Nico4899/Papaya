//
//  PapayaColors.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 13.10.25.
//

import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    static let ui = Logger(subsystem: subsystem, category: "UI")
    static let data = Logger(subsystem: subsystem, category: "Data")
    static let camera = Logger(subsystem: subsystem, category: "Camera")
}
