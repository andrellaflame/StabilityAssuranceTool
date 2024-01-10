//
//  File.swift
//  
//
//  Created by Andrii Sulimenko on 10.01.2024.
//

import Foundation

extension Array {
    func printTuples(description: (Element) -> String) {
            for element in self {
                print(description(element))
            }
        }
}
