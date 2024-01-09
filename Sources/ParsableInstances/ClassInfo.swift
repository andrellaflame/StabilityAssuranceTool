//
//  ClassInfo.swift
//
//
//  Created by Andrii Sulimenko on 09.01.2024.
//

import Foundation

class ClassInfo {
    var name: String
    var functionCount = 0
    var functions: [FunctionInfo] = []
    var variables: [VariableInfo] = []

    init(name: String) {
        self.name = name
    }
}

extension ClassInfo {
    var description: String {
        var xmlString = "--------------------------------------------\n"
        
        xmlString += "<class>\n"
        xmlString += "  <name>\(self.name)</name>\n"
        xmlString += "  <variableCount>\(self.variables.count)</variableCount>\n"
        xmlString += "  <functionCount>\(self.functionCount)</functionCount>\n"
        
        for function in self.functions {
            xmlString += "  <function>\n"
            xmlString += "      <name>\(function.name)</name>\n"
            xmlString += "      <signature>\(function.signature)</signature>\n"
            xmlString += "      <scope>\n\(function.scope)\n      </scope>\n"
            xmlString += "      <functionCalls>\(function.functionCalls)</functionCalls>\n"
            xmlString += "  </function>\n"
        }
        
        for variable in self.variables {
            xmlString += "  <variable>\n"
            xmlString += "      <name>\(variable.name)</name>\n"
            xmlString += "      <declaration>\(variable.declaration)\n      </declaration>\n"
            xmlString += "  </variable>\n"
        }
        
        xmlString += "</class>\n"
        xmlString += "--------------------------------------------\n"
        
        return xmlString
    }
}


