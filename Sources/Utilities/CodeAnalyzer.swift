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
    private let sourceFile: SourceFileSyntax
    private let filePath: String
    /// Stack to keep track of class information during traversal.
    public var classStack: [ClassInfo] = []
    
    init(sourceFile: SourceFileSyntax, filePath: String, viewMode: SyntaxTreeViewMode) {
        self.sourceFile = sourceFile
        self.filePath = filePath
        super.init(viewMode: viewMode)
    }
    
    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        let location = node.positionAfterSkippingLeadingTrivia.location(in: sourceFile)
        
        let classInfo = ClassInfo(
            Declaration(
                name: node.name.text,
                filePath: filePath,
                line: location.line
            )
        )
        
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
        
        let location = node.positionAfterSkippingLeadingTrivia.location(in: sourceFile)
        let functionSignature = node.signature.description
        let functionScope = "\(node.description)"
        
        let functionInfo = FunctionInfo(
            declaration: Declaration(
                name: node.name.text,
                filePath: filePath,
                line: location.line
            ),
            signature: functionSignature,
            scope: functionScope
        )
        
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
            currentFunction.calledFunctions.append(calledFunction.declName.baseName.text)
        }
        
        return .skipChildren
    }
    
    override func visit(_ node: MemberAccessExprSyntax) -> SyntaxVisitorContinueKind {
        guard let currentClass = classStack.last,
              let currentFunction = currentClass.functions.last else {
            return .skipChildren
        }
        
        let accessedVariable = node.declName.baseName.text
        currentFunction.accessedVariables.append(accessedVariable)
        
        return .skipChildren
    }
    
    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        guard let currentClass = classStack.last else {
            return .skipChildren
        }
        
        for binding in node.bindings {
            if let pattern = binding.pattern.as(IdentifierPatternSyntax.self) {
                let location = node.positionAfterSkippingLeadingTrivia.location(in: sourceFile)
                let variableDeclaration = node.description
                
                let variableInfo = VariableInfo(
                    declaration: Declaration(
                        name: pattern.identifier.text,
                        filePath: filePath,
                        line: location.line
                    ),
                    description: variableDeclaration
                )
                
                currentClass.variables.append(variableInfo)
            }
        }
        
        return .skipChildren
    }
}

private extension AbsolutePosition {
    func location(in sourceFile: SourceFileSyntax) -> SourceLocation {
        let sourceLocationConverter = SourceLocationConverter(fileName: "<file>", tree: sourceFile)
        return sourceLocationConverter.location(for: self)
    }
}
