//
//  WeightedMethodPerClass.swift
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
                
                --type custom | represents custom complexity metric that uses response set for the class value from RFC wihtout considering the number of methods in class
                
                
                """
        )
        var type: Complexity = .custom
        
        private func evaluateWMC(for data: [ClassInfo], for mode: Complexity) {
            if data.isEmpty {
                print("Passed data for evaluation of the WMC metric is empty. Check your filepath input.")
            } else {
                print("Here should be some mark for WMC metric.")
            }
        }
        
        private func evaluateUnity(for data: [ClassInfo]) {
            print("evaluateUnity is called")
            
            evaluateWMC(for: data, for: .unity)
        }
        
        private func evaluateMode(for data: [ClassInfo]) {
            print("evaluateMode is called")
            
            evaluateWMC(for: data, for: .custom)
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
            
            switch type {
            case .custom:
                evaluateMode(for: visitorClasses)
            case .unity:
                evaluateUnity(for: visitorClasses)
            }
        }
    }
}
