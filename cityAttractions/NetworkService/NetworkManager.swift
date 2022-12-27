//
//  NetworkManager.swift
//  cityAttractions
//
//  Created by Азат Киракосян on 26.05.2021.
//

import Foundation

class NetworkManager: NetworkService {
    func getIdShowPlaces(completion: @escaping (NetworkData?) -> Void) {
        let parameters = ["radius": "100000",
                          "lat": "52.4354",
                          "lon": "41.2635",
                          "rate": "3h",
                          "format": "json",
                          "kinds": "religion,cultural,architecture"]
     
        sendGetRequest(path: "/0.1/ru/places/radius",
                       host: "api.opentripmap.com",
                       parameters: parameters,
                       completion: completion)
    }
    
    func getDetailedDataPlaces(by id: String, completion: @escaping (DescriptionPlace?) -> Void) {
        sendGetRequest(path: "/0.1/ru/places/xid/\(id)",
                       host: "api.opentripmap.com",
                       parameters: [:],
                       completion: completion)
    }
}

