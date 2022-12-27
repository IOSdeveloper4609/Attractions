//
//  ShowPlaceDataModel.swift
//  cityAttractions
//
//  Created by Азат Киракосян on 26.05.2021.
//

import Foundation

struct NetworkData: Codable {
    var arrayId: [IdPlaces] = []

    init(from decoder: Decoder) throws {
        let object = try decoder.singleValueContainer()
        let result = try object.decode(Array<IdPlaces>.self)
        arrayId.append(contentsOf: result)
    }
}

struct IdPlaces: Codable {
    let xid: String
}

struct DescriptionPlace: Codable {
    let xid: String
    let name: String?
    let kinds: String
    let otm: String?
    let point: Location
    let address: District
    let preview: AvatarImage?
    let wikipediaExtracts: Description?
    
    enum CodingKeys: String, CodingKey {
        case xid
        case otm
        case wikipediaExtracts = "wikipedia_extracts"
        case name
        case preview
        case address
        case kinds
        case point
    }
}

struct Location: Codable {
   let lon: Double
   let lat: Double
}

struct Description: Codable {
    let text: String?
}

struct AvatarImage: Codable {
    let source: URL
}

struct District: Codable {
    let county: String
}

