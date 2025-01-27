//
//  LOCM.swift
//  StabilityAssuranceTool
//
//  Created by Andrii Sulimenko on 2025-01-27.
//

import ArgumentParser
import Foundation

extension StabilityAssuranceTool.StabilityAssuranceEvaluationCommand {
    
    /// LOCM | Lack of Cohesion of Methods
    ///
    /// The response set of a class is a set of methods that can potentially be executed in response to a message received by an object of that class.
    struct LOCM: ParsableCommand {
        // MARK: - Configuration
        static var configuration = CommandConfiguration(
            commandName: "locm",
            abstract: "A cohesion evaluation tool command to calculate the `Lack of Cohesion of Methods` metric for Swift classes.",
            discussion:
                """
                # Lack of Cohesion of Methods (LOCM) Metric

                LOCM is a measure of how cohesive the methods of a class are with respect to the attributes they access.

                ## Calculation:
                - For each pair of methods in a class, the intersection of accessed attributes is computed.
                - LOCM is the sum of the sizes of these intersections, normalized by the number of method pairs.

                ## Interpretation:
                - A **higher LOCM** value indicates greater cohesion, where methods share more attributes.
                - A **lower LOCM** value suggests poor cohesion, indicating methods interact with disjoint sets of attributes.

                ## Usage:
                Use the LOCM metric to identify classes that may need refactoring to improve cohesion and ensure the class adheres to single responsibility principles.
                """
        )
        
        // MARK: - Messages
        /// Message for when the LOCM value is accepted
        static let acceptedMessage = "LOCM metric value is within the accepted range. Consider reviewing your class cohesion."
        /// Message for when the LOCM value is poor
        static let poorMessage = "LOCM metric is poor. Changes to your current model are highly recommended."
        
        // MARK: - Command Options
        @OptionGroup var options: StabilityAssuranceTool.Options
        
        /// Evaluates LOCM stability metric for passed data
        /// - Parameter data: `ClassInfo` array containing gathered information about each class of the directory
        /// - Returns: `ClassInfo` array containing calculated LOCM stability metric value
        func evaluateLOCM(for data: [ClassInfo]) -> [ClassInfo] {
            if data.isEmpty {
                print("Passed data for evaluation of the LOCM metric is empty. Check your filepath input.")
                return data
            } else {
                data.forEach { classInstance in
                    
                    let allAccessedVariables = classInstance.functions.flatMap { $0.accessedVariables }
                    
                    let totalAccesses = allAccessedVariables.count
                    let uniqueVariables = Set(allAccessedVariables).count
                    
                    let result = totalAccesses - uniqueVariables
                    
                    classInstance.LOCM = (result, .unowned)
                }
                return data
            }
        }
        
        // MARK: - Metric run func
        /// Main `ParsableCommand` function for the command execution
        mutating func run() throws {
            guard let path = options.inputFile else {
                throw StabilityAssuranceToolError.missingAttributeArgument("Input filepath")
            }
            
            print("Trying to use LOCM metric at: \(path)")
            
            var visitorClasses: [ClassInfo] = []
            
            if StabilityAssuranceTool().isDirectory(at: path) {
                visitorClasses = try StabilityAssuranceTool().readDirectory(at: path)
            } else {
                visitorClasses = try StabilityAssuranceTool().readFile(at: path)
            }
            
            let evaluatedLOCM = evaluateLOCM(for: visitorClasses)
            let totalLOCM = evaluatedLOCM.reduce(0) { $0 + $1.LOCM.0 }
            
            let average = Double(totalLOCM) / Double(evaluatedLOCM.count)
            let result = Double(round(average * 100) / 100)
            
            options.output.writeReport("\nLOCM value for \(path): \(result)")
        }
    }
}
