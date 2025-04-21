//
//  Colors.swift
//
//
//  Created by Andrii Sulimenko on 10.01.2024.
//

import Foundation

// MARK: - Colors for console output

/// `Colors` struct for console output formatting.
struct Colors {
    /// Reset color code.
    static let reset = "\u{001B}[0;0m"
    /// Black color code.
    static let black = "\u{001B}[0;30m"
    /// Red color code.
    static let red = "\u{001B}[0;31m"
    /// Green color code.
    static let green = "\u{001B}[0;32m"
    /// Yellow color code.
    static let yellow = "\u{001B}[0;33m"
    /// Blue color code.
    static let blue = "\u{001B}[0;34m"
    /// Magenta color code.
    static let magenta = "\u{001B}[0;35m"
    /// Cyan color code.
    static let cyan = "\u{001B}[0;36m"
    /// White color code.
    static let white = "\u{001B}[0;37m"
}
