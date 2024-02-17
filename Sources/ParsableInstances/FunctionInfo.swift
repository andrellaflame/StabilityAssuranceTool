//
//  FunctionInfo.swift
//  
//
//  Created by Andrii Sulimenko on 09.01.2024.
//

import Foundation

/// Represents information about a function.
class FunctionInfo {
    var name: String
    var signature: String
    var scope: String
    var functionCalls: Int
    var calledFunctions: [String] = []
    
    /// Initializes a new instance of `FunctionInfo` with the given parameters.
    /// - Parameters:
    ///   - name: The name of the function.
    ///   - signature: The signature of the function.
    ///   - scope: The scope of the function.
    ///   - functionCalls: The number of times the function is called.
    init(name: String, signature: String, scope: String, functionCalls: Int) {
        self.name = name
        self.signature = signature
        self.scope = scope
        self.functionCalls = functionCalls
    }
}
