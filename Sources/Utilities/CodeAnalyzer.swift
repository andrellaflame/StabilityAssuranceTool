//
//  CodeAnalyzer.swift
//
//
//  Created by Andrii Sulimenko on 04.01.2024.
//

import Foundation
import SwiftSyntax

/// Analyzes Swift code syntax to extract class, function, and variable information.
class CodeAnalyzer: SyntaxVisitor {

    /// Stack to keep track of class information during traversal.
    var classStack: [ClassInfo] = []
    
    /// Total count of classes encountered during traversal.
    var classCount = 0

     override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
         let className = node.name.text
         let classInfo = ClassInfo(name: className)
         
         // Extracting inheritance information if available
         if let inheritanceClause = node.inheritanceClause {
             let baseClasses = inheritanceClause
                 .inheritedTypes
                 .map { $0.description.trimmingCharacters(in: .whitespacesAndCommas) }
                     
             classInfo.classParents = baseClasses
         }
         
         classStack.append(classInfo)
         
         return super.visit(node)
     }
    
    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        guard let currentClass = classStack.last else {
            return .skipChildren
        }
        
        let functionName = node.name.text
        let functionSignature = node.signature.description
        let functionScope = "\(node.description)"
        
        let functionInfo = FunctionInfo(name: functionName, signature: functionSignature, scope: functionScope, functionCalls: 0)
        
        currentClass.functions.append(functionInfo)
        currentClass.functionCount += 1
        
        return .visitChildren
    }
    
    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        guard let currentClass = classStack.last,
              let currentFunction = currentClass.functions.last else {
            return .skipChildren
        }
        if let calledFunction = node.calledExpression.as(MemberAccessExprSyntax.self) {
            currentFunction.functionCalls += 1
            currentFunction.calledFunctions.append(calledFunction.declName.baseName.text)
        }
        
        return .skipChildren
    }
    
    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        guard let currentClass = classStack.last else {
            return .skipChildren
        }
        
        for binding in node.bindings {
            if let pattern = binding.pattern.as(IdentifierPatternSyntax.self) {
                let variableName = pattern.identifier.text
                let variableDeclaration = node.description
                let variableInfo = VariableInfo(name: variableName, declaration: variableDeclaration)
                
                currentClass.variables.append(variableInfo)
            }
        }
        
        return .skipChildren
    }
}
