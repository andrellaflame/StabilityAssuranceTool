//
//  WMC.swift
//
//
//  Created by Andrii Sulimenko on 09.01.2024.
//

import ArgumentParser
import Foundation
import SwiftSyntax
import SwiftParser

extension StabilityAssuranceTool.StabilityAssuranceMark {
    struct WMC: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "wmc",
            abstract: "A stability assurance tool command to evaluate `Weighted Method per Class` metric for Swift projects.",
            discussion:
                """
                # Weighted Method per Class stability metric
                
                WMC is measures the sum of complexity of the methods in a class.
                
                If all method complexities are considered to be unity, then WMC = n,the number of methods. Otherwise, it's (∑Ci) from i = 1 to n, where Ci is previously estimated complexity of the class i.
                
                The larger the value, the more complex and potentially incorrect the structure of the class.
                """
        )
        
        enum Complexity: String, ExpressibleByArgument {
            case custom, unity
        }
        
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
                                .compactMap { $0.functionCalls }
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
        
        mutating func run() throws {
            let path = options.filepath
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
            print("\nWMC value: \(result)")
        }
    }
}
