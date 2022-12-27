//
//  Array + Extensions.swift
//  cityAttractions
//
//  Created by Азат Киракосян on 26.05.2021.
//

import Foundation

extension Array {
    subscript (safe index: Index) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        return self[index]
    }
}

