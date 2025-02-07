//
//  File.swift
//  StabilityAssuranceTool
//
//  Created by Andrii Sulimenko on 2025-01-09.
//

import ArgumentParser
import Foundation
import Yams

// MARK: ParsableArguments
extension StabilityAssuranceTool {
    /// Options for the Stability Assurance Tool.
    struct Options: ParsableArguments {
        @Flag(name: .long, help: "Show extra logging for debugging purposes")
        private var verbose = false

        @Argument(help: "The file path for data collection.")
        var inputFile: String?
        
        @Option(name: .long, help: "Path to the YAML configuration file.")
        var config: String?
        
        @Option(
            help:
                """
                The output format type for the overall stability report.
                
                --output console | printed console output for generated product stability assurance check.
                
                --output html | auto-generaged HTML page for the product stability assurance check report.
                                
                --output `/output_directory` | file output for received stability assurance check report.
                
                NOTE: In order to save generated product stability assurance report to a file, add output file path after input directory path
                """
        )
        var output: OutputFormat = .console
    }
}


/// YAML configuration parsing
extension ParsableArguments {
    static func loadConfiguration(from path: String) -> SATConfiguration? {
        guard FileManager.default.fileExists(atPath: path) else {
            print("Configuration file not found at \(path). Using default settings.")
            return nil
        }
        do {
            let yamlString = try String(contentsOfFile: path, encoding: .utf8)
            let configuration = try YAMLDecoder().decode(SATConfiguration.self, from: yamlString)
            
            print("YAML configuration retrieved successfuly: \(configuration)")
            return configuration
        } catch {
            print("Error parsing YAML configuration: \(error)")
            return nil
        }
    }
}
