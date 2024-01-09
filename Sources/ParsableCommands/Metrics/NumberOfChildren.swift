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
            abstract: "A stability assurance tool command to evaluate `Number of Children` metric for Swift projects"
        )
        
        @OptionGroup var options: StabilityAssuranceTool.Options
        
        mutating func run() throws {
            let path = options.filepath
            print("Trying to use NOC metric at: \(path)")
        }
    }
}

