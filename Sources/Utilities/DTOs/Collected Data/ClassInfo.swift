//
//  ClassInfo.swift
//
//
//  Created by Andrii Sulimenko on 09.01.2024.
//

import Foundation

/// Represents gathered information about a class.
class ClassInfo: DeclarationObservable {
    var declaration: Declaration
    var functionCount = 0
    var functions: [FunctionInfo] = []
    var variables: [VariableInfo] = []
    var classParents: [String] = []
    
    // MARK: Stability metrics values
    /// Weighted Method Count (WMC) metric value and its stability mark.
    var WMC: (Int, SATMark) = (0, .unowned)
    
    /// Response For a Class (RFC) metric value and its stability mark.
    var RFC: (Int, SATMark) = (0, .unowned)
    
    /// Number Of Children (NOC) metric value and its stability mark.
    var NOC: (Int, SATMark) = (0, .unowned)
    
    /// Lack of Cohesion of Methods (LOCM) metric value and its stability mark.
    var LOCM: (Int, SATMark) = (0, .unowned)
    
    /// Initializes a new instance of `ClassInfo` with the given name.
    /// - Parameter name: The name of the class.
    init(_ declaration: Declaration) {
        self.declaration = declaration
    }
}

extension ClassInfo {
    /// A textual representation of the class information.
    var description: String {
        var xmlString = "--------------------------------------------\n"
        
        xmlString += "<class>\n"
        xmlString += "  <name>\(self.declaration.name)</name>\n"
        xmlString += "  <variableCount>\(self.variables.count)</variableCount>\n"
        xmlString += "  <functionCount>\(self.functionCount)</functionCount>\n"
        
        if !self.classParents.isEmpty {
            xmlString += "  <classParents>\n"
            for classParent in self.classParents {
                xmlString += "      <classParentName>\(classParent)</classParentName>\n"
            }
            xmlString += "  </classParents>\n"
        }
        
        xmlString += "  <WMC>\(self.WMC)</WMC>\n"
        xmlString += "  <RFC>\(self.RFC)</RFC>\n"
        xmlString += "  <NOC>\(self.NOC)</NOC>\n"
        xmlString += "  <LOCM>\(self.LOCM)</LOCM>\n"
        
        for function in self.functions {
                        
            xmlString += "  <function>\n"
            xmlString += "      <name>\(function.declaration.name)</name>\n"
            xmlString += "      <signature>\(function.signature)</signature>\n"
            xmlString += "      <scope>\n\(function.scope)\n      </scope>\n"
            xmlString += "      <functionCalls>\(function.calledFunctions.count)</functionCalls>\n"
            xmlString += "      <functionsCalled>\n"
            
            for calledFunction in function.calledFunctions {
                xmlString += "          <functionName>\(calledFunction)</functionName>\n"
            }
            
            xmlString += "      </functionCalls>\n"
            xmlString += "  </function>\n"
        }
        
        for variable in self.variables {
            xmlString += "  <variable>\n"
            xmlString += "      <name>\(variable.declaration.name)</name>\n"
            xmlString += "      <declaration>\(variable.declaration)\n      </declaration>\n"
            xmlString += "  </variable>\n"
        }
        
        xmlString += "</class>\n"
        xmlString += "--------------------------------------------\n"
        
        return xmlString
    }
}


