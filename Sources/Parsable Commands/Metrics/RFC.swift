//
//  RFC.swift
//
//
//  Created by Andrii Sulimenko on 09.01.2024.
//

import ArgumentParser
import Foundation

extension StabilityAssuranceTool.StabilityAssuranceEvaluationCommand {
    
    /// RFC | Response for Class stability metric
    ///
    /// The response set of a class is a set of methods that can potentially be executed in response to a message received by an object of that class.
    struct RFC: ParsableCommand {
        // MARK: - Configuration
        static var configuration = CommandConfiguration(
            commandName: "rfc",
            abstract: "A stability assurance tool command to evaluate the `Response for Class` (RFC) metric for Swift projects.",
            discussion:
                """
                # Response for Class (RFC) Stability Metric

                The Response for Class (RFC) metric measures the stability of a class by evaluating the number of methods that can be potentially executed in response to a message sent to an object of that class.

                ## Calculation:
                - The response set of a class includes all methods directly defined in the class, as well as methods of other classes invoked by the methods of this class.
                - RFC is simply the number of methods in this response set.

                ## Interpretation:
                - A **higher RFC** value indicates greater complexity and potential instability due to an increased number of methods involved.
                - A **lower RFC** value suggests simplicity and potentially better maintainability.

                ## Usage:
                Use the RFC metric to identify classes that may require refactoring to reduce complexity and ensure they adhere to stability principles.
                """
        )
        
        // MARK: - Messages
        /// Message for when the RFC value is accepted
        static let acceptedMessage = "RFC metric value is within the accepted range. Consider reviewing your class response complexity."
        /// Message for when the RFC value is poor
        static let poorMessage = "RFC metric is poor. Consider simplifying class methods or reducing interdependencies."
        
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
                            .reduce(0) { $0 + 1 + $1.calledFunctions.count }
                        , .unowned
                    )
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
            
            options.output.writeReport("\nRFC value for \(path): \(result)")
        }
    }
}
