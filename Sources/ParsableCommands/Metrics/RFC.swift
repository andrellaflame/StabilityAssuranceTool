//
//  RFC.swift
//
//
//  Created by Andrii Sulimenko on 09.01.2024.
//

import ArgumentParser
import Foundation
import SwiftSyntax
import SwiftParser

extension StabilityAssuranceTool.StabilityAssuranceMark {
    
    /// RFC | Response for Class stability metric
    ///
    /// The response set of a class is a set of methods that can potentially be executed in response to a message received by an object of that class.
    struct RFC: ParsableCommand {
        // MARK: - Configuration
        static var configuration = CommandConfiguration(
            commandName: "rfc",
            abstract: "A stability assurance tool command to evaluate `Response for Class` metric for Swift projects.",
            discussion:
                """
                # Response for Class stability metric
                
                The response set of a class is a set of methods that can potentially be executed in response to a message received by an object of that class.
                
                RFC is simply the number of methods in the set.
                """
        )
        
        // MARK: - Command Options
        @OptionGroup var options: StabilityAssuranceTool.Options
        
        /// Evaluates RFC stability metric for passed data
        /// - Parameter data: `ClassInfo` array containing gathered information about each class of the directory
        /// - Returns: `ClassInfo` array containing calculated RFC stability metric value
        func evaluateRFC(for data: [ClassInfo]) -> [ClassInfo] {
            if data.isEmpty {
                print("Passed data for evaluation of the RFC metric is empty. Check your filepath input.")
                return data
                
            } else {
                data.forEach { classInstance in
                    classInstance.RFC = (
                        classInstance.functions
                            .reduce(0) { $0 + 1 + $1.functionCalls }
                        , .unowned
                    )
                }
                return data
            }
        }
        
        // MARK: - Metric run func
        /// Main `ParsableCommand` function for the command execution
        mutating func run() throws {
            let path = options.filepath
            print("Trying to use RFC metric at: \(path)")
            
            var visitorClasses: [ClassInfo] = []
            
            if StabilityAssuranceTool().isDirectory(at: path) {
                visitorClasses = try StabilityAssuranceTool().readDirectory(at: path)
            } else {
                visitorClasses = try StabilityAssuranceTool().readFile(at: path)
            }
            
            let evaluatedRFC = evaluateRFC(for: visitorClasses)
            let totalRFC = evaluatedRFC.reduce(0) { $0 + $1.RFC.0 }
            
            let average = Double(totalRFC) / Double(evaluatedRFC.count)
            let result = Double(round(average * 100) / 100)
            
            print("\nRFC value: \(result)")
        }
    }
}
