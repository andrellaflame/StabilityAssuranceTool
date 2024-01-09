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
            abstract: "A stability assurance tool command to evaluate `Weighted Method per Class` metric for Swift projects"
        )
        
        @OptionGroup var options: StabilityAssuranceTool.Options
        
        mutating func run() throws {
            let path = options.filepath
            print("Trying to use WMC metric at: \(path)")
        }
    }
}
