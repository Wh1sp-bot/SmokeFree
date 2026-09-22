import Foundation
import os

/// Централізоване логування (замість розкиданих `print`).
enum Log {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "SmokeFree"

    static let storage = Logger(subsystem: subsystem, category: "storage")
    static let haptics = Logger(subsystem: subsystem, category: "haptics")
    static let network = Logger(subsystem: subsystem, category: "network")
}
