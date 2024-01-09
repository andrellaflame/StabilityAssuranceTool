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
            abstract: "A stability assurance tool command to evaluate `Weighted Method per Class` metric for Swift projects."
        )
        
        @OptionGroup var options: StabilityAssuranceTool.Options
        
        private func evaluateWMC(for data: [ClassInfo]) {
            if data.isEmpty {
                print("Passed data for evaluation of the WMC metric is empty. Check your filepath input.")
            } else {
                print("Here should be some mark for WMC metric.")
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
            
            evaluateWMC(for: visitorClasses)
        }
    }
}
