//
//  StabilityAssuranceCheck.swift
//
//
//  Created by Andrii Sulimenko on 10.01.2024.
//

import ArgumentParser
import Foundation
import SwiftSyntax
import SwiftParser

extension StabilityAssuranceTool.StabilityAssuranceMark {
    struct StabilityAssuranceCheck: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "stats",
            abstract: "The main stability assurance tool command to evaluate `Overall stability mark` for Swift projects.",
            discussion:
                """
                # Overall stability mark
                
                This mark is evaluated using results of all metrics counted together for the project in passed directory. It uses predefined tables of values for particular metrics.
                """
        )
        
        @OptionGroup var options: StabilityAssuranceTool.Options
        
        private func evaluateProduct(at path: String, for data: [ClassInfo]) -> [(any Numeric, String)] {
            var result: [(any Numeric, String)] = []
            
            let WMCvalue = WMC().evaluateWMC(for: data, type: .custom)
            let RFCvalue = RFC().evaluateRFC(for: data)
            let NOCvalue = NOC().evaluateNOC(for: data)
            
            result.append((WMCvalue, "WMC"))
            result.append((RFCvalue, "RFC"))
            result.append((NOCvalue, "NOC"))
            
            return result
        }
        
        mutating func run() throws {
            let path = options.filepath
            print("Trying to apply metrics to evaluate stability for: \(path)")
            
            var visitorClasses: [ClassInfo] = []
            
            if StabilityAssuranceTool().isDirectory(at: path) {
                visitorClasses = try StabilityAssuranceTool().readDirectory(at: path)
            } else {
                visitorClasses = try StabilityAssuranceTool().readFile(at: path)
            }
            
            let tupledResults = evaluateProduct(at: path, for: visitorClasses)
            let linesCount = LinesCounter().countLines(at: path).last?.0
            
            print(
                """
                
                --------------------------------------------
                    System analyzed: \(Colors.red)Swift 􀫊\(Colors.reset)
                --------------------------------------------
                    Project Overview
                
                    Number of classes: \(visitorClasses.count) 􀍞
                    Lines of code: \(linesCount ?? 0) 􀣠
                
                --------------------------------------------
                    Metrics Summary \(Colors.green)􀇺\(Colors.reset)
                
                """
            )
            
            tupledResults.printTuples { tuple in
                return "    \(tuple.1): \(tuple.0)"
            }
            
            print("\n--------------------------------------------\n")
        }
    }
}

