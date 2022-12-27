//
//  SettingManager.swift
//  cityAttractions
//
//  Created by Азат Киракосян on 11.06.2021.
//

import UIKit

enum VisibleType: String {
    case name
    case coordinates
    case empty
    
    init(index: Int) {
        switch index {
        case 0:
            self = .name
        case 1:
            self = .coordinates
        default:
            self = .empty
        }
    }
}

final class SettingManager {
    static let shared = SettingManager()
    private let visibleTypeKey = "kVisibleType"
    private let defaultVisibleType = VisibleType.name
    
    private var storage = UserDefaults.standard
    var visibleType: VisibleType? {
        guard let visibleTypeString = storage.object(forKey: visibleTypeKey) as? String else {
            return defaultVisibleType
        }
        
        return VisibleType(rawValue: visibleTypeString)
    }
    
    private init() {}
    
    func saveVisibleType(with type: VisibleType) {
        storage.set(type.rawValue, forKey: visibleTypeKey)
    }
}
