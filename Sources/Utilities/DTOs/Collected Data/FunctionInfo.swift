//
//  FunctionInfo.swift
//  
//
//  Created by Andrii Sulimenko on 09.01.2024.
//

import Foundation

/// Represents information about a function.
class FunctionInfo: DeclarationObservable {
    var declaration: Declaration
    var signature: String
    var scope: String
    var calledFunctions: [String] = []
    var accessedVariables: [String] = []
    
    /// Initializes a new instance of `FunctionInfo` with the given parameters.
    /// - Parameters:
    ///   - name: The name of the function.
    ///   - signature: The signature of the function.
    ///   - scope: The scope of the function.
    init(declaration: Declaration, signature: String, scope: String) {
        self.declaration = declaration
        self.signature = signature
        self.scope = scope
    }
}
