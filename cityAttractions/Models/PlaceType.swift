//
//  PlaceType.swift
//  cityAttractions
//
//  Created by Азат Киракосян on 04.06.2021.
//

import Foundation

enum PlaceType: String {
    case religion = "религия"
    case cultural = "культура"
    case architecture = "архитектура"
    case museum = "музей"
    case other = "другое"
    
    
    init(kinds: String) {
        let kind = kinds.split{ $0 == "," }.map(String.init)
        let result = kind.first ?? ""
        
        switch result {
        case "religion":
            self = .religion
        case "cultural":
            self = .cultural
        case "architecture":
            self = .architecture
        case "museums":
            self = .museum
        default:
            self = .other
        }
    }
    
    init(index: Int) {
        switch index {
        case 1:
            self = .architecture
        case 2:
            self = .cultural
        case 3:
            self = .museum
        case 4:
            self = .religion
        default:
            self = .other
        }
    }
}
