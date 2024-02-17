//
//  File.swift
//  
//
//  Created by Andrii Sulimenko on 09.01.2024.
//

import Foundation

/// Represents information about a variable.
class VariableInfo {
    var name: String
    var declaration: String
    
    /// Initializes a new instance of `VariableInfo` with the given parameters.
    /// - Parameters:
    ///   - name: The name of the variable.
    ///   - declaration: The declaration of the variable.
    init(name: String, declaration: String) {
        self.name = name
        self.declaration = declaration
    }
}
