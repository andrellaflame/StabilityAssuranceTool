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
    struct NOC: ParsableCommand {
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
        
        @OptionGroup var options: StabilityAssuranceTool.Options
        
        func evaluateNOC(for data: [ClassInfo]) -> Double {
            if data.isEmpty {
                print("Passed data for evaluation of the NOC metric is empty. Check your filepath input.")
                
                return 0
            } else {
                for classInstance in data {
                    classInstance.numberOfChildren = data
                        .filter { $0.classParents.contains(classInstance.name) }
                        .count
                }
                
                let average: Double = data.reduce(0.0) {
                    $0 + Double($1.numberOfChildren) / Double(data.count)
                }
                
                let result = Double(round(average * 100) / 100)
                return result
            }
        }
        
        mutating func run() throws {
            let path = options.filepath
            print("Trying to use NOC metric at: \(path)")
            
            var visitorClasses: [ClassInfo] = []
            
            if StabilityAssuranceTool().isDirectory(at: path) {
                visitorClasses = try StabilityAssuranceTool().readDirectory(at: path)
            } else {
                visitorClasses = try StabilityAssuranceTool().readFile(at: path)
            }
            
            let result = evaluateNOC(for: visitorClasses)
            print("\nNOC value: \(result)")
        }
    }
}

