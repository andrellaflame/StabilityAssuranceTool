//
//  SATReport.swift
//
//
//  Created by Andrii Sulimenko on 01.02.2024.
//

import Foundation

struct SATReport {
    let system: String
    let projectDirectory: String
    let numberOfClasses: Int
    let linesOfCode: Int
    let projectScale: String
    let WMC: Metric
    let RFC: Metric
    let NOC: Metric
    let overallMark: (String, SATMark)
    let note: String
    let detailedDescription: [ClassDescription]
}

struct ClassDescription {
    let name: String
    let WMCResult: String
    let RFCResult: String
    let NOCResult: String
}

struct Metric {
    let value: any Numeric
    let mark: SATMark
}
