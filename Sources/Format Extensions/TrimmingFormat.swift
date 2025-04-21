//
//  TrimmingFormat.swift
//
//
//  Created by Andrii Sulimenko on 10.01.2024.
//

import Foundation

// MARK: - CharacterSet Extension

/// Extension to `CharacterSet` providing additional character sets.
extension CharacterSet {
    /// `whitespacesAndCommas` function returns a `character set` containing whitespaces and commas.
    static var whitespacesAndCommas: CharacterSet {
        var characterSet = self.whitespaces
        characterSet.insert(charactersIn: ",")
        return characterSet
    }
}
