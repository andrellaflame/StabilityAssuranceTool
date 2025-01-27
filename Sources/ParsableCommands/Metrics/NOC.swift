//
//  NOC.swift
//
//
//  Created by Andrii Sulimenko on 09.01.2024.
//

import ArgumentParser
import Foundation

extension StabilityAssuranceTool.StabilityAssuranceEvaluationCommand {
    /// NOC | Number of Children stability metric
    ///
    /// NOC equals the number of immediate child classes derived from a base class. NOC measures the breadth of a class hierarchy, where maximum DIT measures the depth.
    struct NOC: ParsableCommand {
        
        // MARK: - Configuration
        static var configuration = CommandConfiguration(
            commandName: "noc",
            abstract: "A stability assurance tool command to evaluate the `Number of Children` (NOC) metric for Swift projects.",
            discussion:
                """
                # Number of Children (NOC) Stability Metric

                The Number of Children (NOC) metric measures the breadth of a class hierarchy by counting the number of immediate subclasses derived from a base class.

                ## Calculation:
                - NOC is the count of all direct child classes that inherit from a specific base class.

                ## Interpretation:
                - A **higher NOC** value can indicate greater reuse and extensibility, which are desirable properties in object-oriented design.
                - However, very high NOC might increase the testing burden due to the larger number of subclasses.

                ## Usage:
                Use the NOC metric to assess the design breadth of a class hierarchy and identify opportunities to optimize inheritance structure for better maintainability and stability.
                """
        )
        
        // MARK: - Messages
        /// Message for when the metric value is accepted
        static let acceptedMessage = "NOC metric value is within the accepted range, consider reviewing your class hierarchy breadth."
        /// Message for when the metric value is poor
        static let poorMessage = "NOC metric value is poor, indicating a potential issue with class hierarchy breadth."
        
        // MARK: - Command Options
        @OptionGroup var options: StabilityAssuranceTool.Options
        
        /// Evaluates NOC stability metric for passed data
        /// - Parameter data: `ClassInfo` array containing gathered information about each class of the directory
        /// - Returns: `ClassInfo` array containing calculated NOC stability metric value
        func evaluateNOC(for data: [ClassInfo]) -> [ClassInfo] {
            if data.isEmpty {
                print("Passed data for evaluation of the NOC metric is empty. Check your filepath input.")
                return data
            } else {
                for classInstance in data {
                    classInstance.NOC = (
                        data
                            .filter { $0.classParents.contains(classInstance.declaration.name) }
                            .count
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
            
            print("Trying to use NOC metric at: \(path)")
            
            var visitorClasses: [ClassInfo] = []
            
            if StabilityAssuranceTool().isDirectory(at: path) {
                visitorClasses = try StabilityAssuranceTool().readDirectory(at: path)
            } else {
                visitorClasses = try StabilityAssuranceTool().readFile(at: path)
            }
            
            let evaluatedNOC = evaluateNOC(for: visitorClasses)
            let average: Double = evaluatedNOC.reduce(0.0) {
                $0 + Double($1.NOC.0) / Double(evaluatedNOC.count)
            }
            
            let result = Double(round(average * 100) / 100)
            options.output.writeReport("\nNOC value for \(path): \(result)")
        }
    }
}

