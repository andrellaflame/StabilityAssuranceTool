//
//  TupleArrayPrintFormat.swift
//
//
//  Created by Andrii Sulimenko on 10.01.2024.
//

import Foundation

// MARK: - Array Extension

/// Extension to `Array` providing additional functionality for printing tuples.
extension Array {
    /// Prints elements of the array using a provided description for each element.
    ///
    /// - Parameters:
    ///     - description: A closure that takes an element of the array and returns a string description.
    func printTuples(description: (Element) -> String) {
        for element in self {
            print(description(element))
        }
    }
}
