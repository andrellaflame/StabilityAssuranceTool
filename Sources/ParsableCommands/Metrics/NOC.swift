//
//  NOC.swift
//
//
//  Created by Andrii Sulimenko on 09.01.2024.
//

import ArgumentParser
import Foundation
import SwiftSyntax
import SwiftParser

extension StabilityAssuranceTool.StabilityAssuranceMark {
    /// NOC | Number of Children stability metric
    ///
    /// NOC equals the number of immediate child classes derived from a base class. NOC measures the breadth of a class hierarchy, where maximum DIT measures the depth.
    struct NOC: ParsableCommand {
        
        // MARK: - Configuration
        static var configuration = CommandConfiguration(
            commandName: "noc",
            abstract: "A stability assurance tool command to evaluate `Number of Children` metric for Swift projects.",
            discussion:
                """
                # Number of Children stability metric
                
                NOC equals the number of immediate child classes derived from a base class. NOC measures the breadth of a class hierarchy, where maximum DIT measures the depth.
                
                High NOC has been found to indicate fewer faults. This may be due to high reuse, which is desirable.
                """
        )
        
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
                            .filter { $0.classParents.contains(classInstance.name) }
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
            let path = options.filepath
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
            print("\nNOC value: \(result)")
        }
    }
}

