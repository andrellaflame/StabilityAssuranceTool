//
//  File.swift
//  
//
//  Created by Andrii Sulimenko on 10.01.2024.
//

import Foundation

// MARK: CharacterSet extension
extension CharacterSet {
    static var whitespacesAndCommas: CharacterSet {
        var characterSet = self.whitespaces
        characterSet.insert(charactersIn: ",")
        return characterSet
    }
}
