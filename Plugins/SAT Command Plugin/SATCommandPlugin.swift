//
//  SATCommandPlugin.swift
//  StabilityAssuranceTool
//
//  Created by Andrii Sulimenko on 2025-04-21.
//

import Foundation
import PackagePlugin


@main
struct SATCommandPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) throws {
        try performCommandWithinContext(context: context, arguments: arguments)
    }
}

#if canImport(XcodeProjectPlugin)

import XcodeProjectPlugin

extension SATCommandPlugin: XcodeCommandPlugin {
    func performCommand(context: XcodePluginContext, arguments: [String]) throws {
        try performCommandWithinContext(context: context, arguments: arguments)
    }
}

#endif

extension SATCommandPlugin {
    private func performCommandWithinContext(context: some CommandContext, arguments: [String]) throws {
        let command = arguments.first ?? "stats"
        
        switch command {
        case "stats":
            Diagnostics.remark("Stability check was initiated.")
        case "countLines":
            Diagnostics.remark("Lines of Code Metric check was initiated.")
        case "locm":
            Diagnostics.remark("Lack of Cohesion of Methods (LOCM) Metric check was initiated.")
        case "rfc":
            Diagnostics.remark("Response for Class (RFC) Stability Metric check was initiated.")
        case "wmc":
            Diagnostics.remark("Weighted Method per Class (WMC) Stability Metric check was initiated.")
        default:
            Diagnostics.error("Command was not recognized by Stability Assurance Tool. Verify command input.")
            return
        }
        
        let process = Process()
        
        process.currentDirectoryURL = URL(fileURLWithPath: context.workingDirectory)
        process.executableURL = URL(fileURLWithPath: try context.tool)
        process.arguments = [command] + arguments
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus != 0 {
            Diagnostics.error("Stability check failed with exit code \(process.terminationStatus)")
        } else {
            Diagnostics.remark("Stability check completed successfully.")
        }
    }
}
