//
//  SATReport.swift
//
//
//  Created by Andrii Sulimenko on 01.02.2024.
//

import Foundation

/// Represents a Stability Assurance Tool (SAT) report struct value.
struct SATReport {
    /// The name of the system being analyzed.
        let system: String
        
        /// The directory of the project being analyzed.
        let projectDirectory: String
        
        /// The number of classes in the project.
        let numberOfClasses: Int
        
        /// The total lines of code in the project.
        let linesOfCode: Int
        
        /// The scale of the project (e.g., small, medium, large).
        let projectScale: String
        
        /// Weighted Method Count (WMC) metric value and mark.
        let WMC: Metric
        
        /// Response For a Class (RFC) metric value and mark.
        let RFC: Metric
        
        /// Number Of Children (NOC) metric value and mark.
        let NOC: Metric
        
        /// The overall stability mark of the project.
        let overallMark: (String, SATMark)
        
        /// Additional notes or comments about the project.
        let note: String
        
        /// Detailed descriptions of each class in the project.
        let detailedDescription: [ClassDescription]
}

/// Represents the description of a class in the SAT report.
struct ClassDescription {
    /// The name of the class.
    let name: String
    
    /// The result of the Weighted Method Count (WMC) metric for the class.
    let WMCResult: String
    
    /// The result of the Response For a Class (RFC) metric for the class.
    let RFCResult: String
    
    /// The result of the Number Of Children (NOC) metric for the class.
    let NOCResult: String
}

/// Represents a metric value and its corresponding stability mark.
struct Metric {
    /// The value of the metric.
    let value: any Numeric
    
    /// The stability mark associated with the metric.
    let mark: SATMark
}
