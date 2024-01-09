//
//  ResponseForClass.swift
//
//
//  Created by Andrii Sulimenko on 09.01.2024.
//

import ArgumentParser
import Foundation
import SwiftSyntax
import SwiftParser

extension StabilityAssuranceTool.StabilityAssuranceMark {
    struct RFC: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "rfc",
            abstract: "A stability assurance tool command to evaluate `Response for Class` metric for Swift projects."
        )
        
        @OptionGroup var options: StabilityAssuranceTool.Options
        
        private func evaluateRFC(for data: [ClassInfo]) {
            if data.isEmpty {
                print("Passed data for evaluation of the RFC metric is empty. Check your filepath input.")
            } else {
                print("Here should be some mark for RFC metric.")
            }
        }
        
        mutating func run() throws {
            let path = options.filepath
            print("Trying to use RFC metric at: \(path)")
            
            var visitorClasses: [ClassInfo] = []
            
            if StabilityAssuranceTool().isDirectory(at: path) {
                visitorClasses = try StabilityAssuranceTool().readDirectory(at: path)
            } else {
                visitorClasses = try StabilityAssuranceTool().readFile(at: path)
            }
            
            evaluateRFC(for: visitorClasses)
        }
    }
}
