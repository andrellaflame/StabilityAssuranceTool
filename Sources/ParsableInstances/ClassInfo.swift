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
    var classParents: [String] = []
    
    // MARK: Stability metrics values
    var WMC: (Int, SATMark) = (0, .unowned)
    var RFC: (Int, SATMark) = (0, .unowned)
    var NOC: (Int, SATMark) = (0, .unowned)

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
        
        if !self.classParents.isEmpty {
            xmlString += "  <classParents>\n"
            for classParent in self.classParents {
                xmlString += "      <classParentName>\(classParent)</classParentName>\n"
            }
            xmlString += "  </classParents>\n"
        }
        
        xmlString += "  <numberOfChildren>\(self.NOC)</numberOfChildren>\n"
        
        for function in self.functions {
            
            let calledFunctions = function.calledFunctions
            
            xmlString += "  <function>\n"
            xmlString += "      <name>\(function.name)</name>\n"
            xmlString += "      <signature>\(function.signature)</signature>\n"
            xmlString += "      <scope>\n\(function.scope)\n      </scope>\n"
            xmlString += "      <functionCalls>\(function.functionCalls)</functionCalls>\n"
            xmlString += "      <functionsCalled>\n"
            
            for calledFunction in calledFunctions {
                xmlString += "          <functionName>\(calledFunction)</functionName>\n"
            }
            
            xmlString += "      </functionCalls>\n"
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


