//
//  FunctionInfo.swift
//  
//
//  Created by Andrii Sulimenko on 09.01.2024.
//

import Foundation

class FunctionInfo {
    var name: String
    var signature: String
    var scope: String
    var functionCalls: Int
    
    init(name: String, signature: String, scope: String, functionCalls: Int) {
        self.name = name
        self.signature = signature
        self.scope = scope
        self.functionCalls = functionCalls
    }
}
