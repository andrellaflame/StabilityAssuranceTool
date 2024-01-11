//
//  SATReportWriter.swift
//
//
//  Created by Andrii Sulimenko on 11.01.2024.
//

import Foundation

struct SATReportWriter {
    let projectDirectory: String
    let projectScale: ProjectSize
    
    let evaluatedMetrics: [(String, any Numeric, SATMark)]
    let evaluatedData: [ClassInfo]
    
    var description: String {
        
        let (_, valueWMC, markWMC) = evaluatedMetrics
            .filter { $0.0 == "WMC" }
            .first ?? ("WMC", 0, .unowned)
        
        let (_, valueRFC, markRFC) = evaluatedMetrics
            .filter { $0.0 == "RFC" }
            .first ?? ("RFC", 0, .unowned)
        
        let (_, valueNOC, markNOC) = evaluatedMetrics
            .filter { $0.0 == "NOC" }
            .first ?? ("NOC", 0, .unowned)
        
        let (_, valueLOC, _) = evaluatedMetrics
            .filter { $0.0 == "LOC" }
            .first ?? ("LOC", 0, .unowned)
        
        var overallMark: (String, SATMark) = ("", .unowned)
        
        if markWMC == .good && markNOC == .good
            || markWMC == .accepted && markRFC == .good && markNOC == .good
            || markWMC == .good && markRFC == .good && markNOC == .accepted {
            
            overallMark = ("\(Colors.green)Good\(Colors.reset)", .good)
        } else if markRFC == .good && markNOC == .good
                    || markWMC == .good && markRFC == .poor && markNOC == .accepted
                    || markWMC == .accepted && markRFC == .poor && markNOC == .good
                    || markWMC == .accepted && markRFC == .poor && markNOC == .accepted
                    || markWMC == .accepted && markRFC == .accepted && markNOC == .accepted {
            
            overallMark = ("\(Colors.yellow)Accepted\(Colors.reset)", .accepted)
        } else {
            overallMark = ("\(Colors.red)Poor\(Colors.reset)", .poor)
        }
        
        var detailtedDescription = ""
        
        for classInstance in evaluatedData {
            detailtedDescription += "\n     * Class \(classInstance.name)\n"
            
            detailtedDescription += generateComment(metric: "WMC", metricValue: classInstance.WMC.0, mark: classInstance.WMC.1)
            detailtedDescription += generateComment(metric: "RFC", metricValue: classInstance.RFC.0, mark: classInstance.RFC.1)
            detailtedDescription += generateComment(metric: "NOC", metricValue: classInstance.NOC.0, mark: classInstance.NOC.1)
        }
        
        let reportContext =
                        """

                                   \(Colors.green)PRODUCT STABILITY EVALUATION REPORT\(Colors.reset)
                        
                            ------------------------------------------------
                                System analyzed: \(Colors.red)Swift 􀫊\(Colors.reset)
                            ------------------------------------------------
                                Project Overview
                        
                                􀈖  Project directory: \(projectDirectory)
                                􀍞  Number of classes: \(evaluatedData.count)
                                􀣠  Lines of code: \(valueLOC)
                                􀵬  Project scale: \(projectScale.rawValue)
                        
                            ------------------------------------------------
                                Metrics Summary \(Colors.green)􀇺\(Colors.reset)
                                
                                WMC (`Weighted Method per Class`): \(valueWMC)
                                    - mark: \(markWMC)
                                RFC (`Response for Class`): \(valueRFC)
                                    - mark: \(markRFC)
                                NOC (`Number of Children`): \(valueNOC)
                                    - mark: \(markNOC)
                                
                                Overall mark: \(overallMark.0)
                            
                                📎 \(Colors.yellow)NOTE:\(Colors.reset) \(generateComment(metric: "Overall result", mark: overallMark.1))
                        
                            ------------------------------------------------
                                Detailed description 􀬸
                                
                                \(detailtedDescription)
                        
                        """
        return reportContext
    }
    
    private func generateComment(metric: String, metricValue: Int = 0, mark: SATMark = .unowned) -> String {
        var comment = ""
        
        switch metric {
        case "WMC":
            comment = "         WMC mark: \(mark.rawValue) (value: \(metricValue))\n"
        case "RFC":
            comment = "         RFC mark: \(mark.rawValue) (value: \(metricValue))\n"
        case "NOC":
            comment = "         NOC mark: \(mark.rawValue) (value: \(metricValue))\n"
        default:
            if mark == .good {
                comment =
                    """
                    The evaluated product demonstrates stability,
                                aligning with stability metrics that indicate a
                                satisfactory level of stability.
                    """
            } else if mark == .accepted {
                comment =
                    """
                    The evaluated product shows an acceptable level of 
                                stability, meeting the criteria outlined in the stability metrics.
                                Recommendations for improvement may be considered
                                to enhance overall stability further.
                    """
            } else {
                comment =
                    """
                    The evaluated product indicates areas for 
                                improvement in stability based on the applied
                                stability metrics. Consideration of significant
                                adjustments or enhancements is advised to
                                achieve a higher level of stability.
                    """
            }
        }
        
        return comment
    }
}
