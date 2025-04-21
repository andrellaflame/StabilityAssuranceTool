//
//  WMC.swift
//
//
//  Created by Andrii Sulimenko on 09.01.2024.
//

import ArgumentParser
import Foundation

extension StabilityAssuranceTool.StabilityAssuranceEvaluationCommand {
    /// WMC | Weighted Method per Class stability metric
    ///
    /// WMC is measures the sum of complexity of the methods in a class.
    struct WMC: ParsableCommand {
        
        // MARK: - Configuration
        static var configuration = CommandConfiguration(
            commandName: "wmc",
            abstract: "A stability assurance tool command to evaluate `Weighted Method per Class` metric for Swift projects.",
            discussion:
                """
                # Weighted Method per Class (WMC) Stability Metric

                The Weighted Method per Class (WMC) metric measures the sum of the complexities of the methods in a class, reflecting its overall complexity.

                ## Calculation:
                If all method complexities are considered to be unity, then WMC = n,the number of methods. Otherwise, it's (∑Ci) from i = 1 to n, where Ci is previously estimated complexity of the class i.
                
                ## Interpretation:
                - A **higher WMC** value indicates greater complexity, which can make the class harder to understand, maintain, and test.
                - A **lower WMC** value suggests simplicity and better maintainability.

                ## Usage:
                Use the WMC metric to evaluate the structural complexity of classes and identify candidates for refactoring to improve code quality and maintainability.
                """
        )
        
        /// Enum containing `ExpressibleByArgument` options for WMC `ParsableCommand`
        enum Complexity: String, ExpressibleByArgument {
            case custom, unity
        }
        
        // MARK: - Messages
        /// Message for when the WMC value is accepted
        static let acceptedMessage = "WMC metric value is within the accepted range. Consider reviewing the number of methods in this class."
        /// Message for when the WMC value is poor
        static let poorMessage = "WMC metric is poor. Consider reducing method complexity or refactoring large classes."
        
        // MARK: - Command Options
        @OptionGroup var options: StabilityAssuranceTool.Options
        
        @Option(
            help:
                """
                The complexity value type for the class to provide.
                
                --type unity | represents all method complexities that are considered to be unity, which implies that the number of called methods is the main complexity factor.
                
                --type custom | represents custom complexity metric that uses response set for the class value from RFC wihtout considering the number of methods in class.
                
                
                """
        )
        var type: Complexity = .custom
        
        /// Evaluates WMC stability metric for passed data
        /// - Parameter data: `ClassInfo` array containing gathered information about each class of the directory
        /// - Parameter type: `Complexity` option for WMC metric
        /// - Returns: `ClassInfo` array containing calculated WMC stability metric value
        func evaluateWMC(for data: [ClassInfo], type: Complexity) -> [ClassInfo] {
            if data.isEmpty {
                print("Passed data for evaluation of the WMC metric is empty. Check your filepath input.")
                return data
            } else {
                switch type {
                case .custom:
                    data.forEach { classInstance in
                        classInstance.WMC = (
                            classInstance.functions
                                .compactMap { $0.calledFunctions.count }
                                .reduce(0, +)
                            , .unowned
                        )
                    }
                case .unity:
                    data.forEach { $0.WMC = ($0.functionCount, .unowned) }
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
            
            print("Trying to use WMC metric at: \(path)")
            
            var visitorClasses: [ClassInfo] = []
            
            if StabilityAssuranceTool().isDirectory(at: path) {
                visitorClasses = try StabilityAssuranceTool().readDirectory(at: path)
            } else {
                visitorClasses = try StabilityAssuranceTool().readFile(at: path)
            }
            
            var average: Double = 0
            
            switch type {
            case .custom:
                let evaluatedWMC = evaluateWMC(for: visitorClasses, type: .custom)
                let totalWMC = evaluatedWMC.reduce(0) { $0 + $1.WMC.0 }
                
                average = Double(totalWMC) / Double(evaluatedWMC.count)
                
            case .unity:
                let evaluatedWMC = evaluateWMC(for: visitorClasses, type: .unity)
                average = evaluatedWMC.reduce(0.0) {
                    $0 + Double($1.functionCount) / Double(evaluatedWMC.count)
                }
            }
            
            let result = Double(round(average * 100) / 100)
            options.output.writeReport("\nWMC value for \(path): \(result)")
        }
    }
}
