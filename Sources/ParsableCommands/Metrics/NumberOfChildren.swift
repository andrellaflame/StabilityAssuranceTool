//
//  NumberOfChildren.swift
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
            abstract: "A stability assurance tool command to evaluate `Number of Children` metric for Swift projects."
        )
        
        @OptionGroup var options: StabilityAssuranceTool.Options
        
        private func evaluateNOC(for data: [ClassInfo]) {
            if data.isEmpty {
                print("Passed data for evaluation of the NOC metric is empty. Check your filepath input.")
            } else {
                print("Here should be some mark for NOC metric.")
                
                for classInstance in data {
                    classInstance.numberOfChildren = data
                        .filter { $0.classParents.contains(classInstance.name) }
                        .count
                }
                
                let average: Double = data.reduce(0.0) {
                    $0 + Double($1.numberOfChildren) / Double(data.count)
                }
                
                print("NOC value: \(average)")
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
            
            evaluateNOC(for: visitorClasses)
        }
    }
}

