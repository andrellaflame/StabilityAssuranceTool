//
//  File.swift
//  
//
//  Created by Andrii Sulimenko on 09.01.2024.
//

import Foundation

/// Represents information about a variable.
class VariableInfo: DeclarationObservable {
    var declaration: Declaration
    var description: String
    
    /// Initializes a new instance of `VariableInfo` with the given parameters.
    /// - Parameters:
    ///   - declaration: The declaration of the variable.
    ///   - description: The description of the variable.
    init(declaration: Declaration, description: String) {
        self.declaration = declaration
        self.description = description
    }
}
