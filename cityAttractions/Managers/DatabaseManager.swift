//
//  DatebaseManager.swift
//  cityAttractions
//
//  Created by Азат Киракосян on 15.06.2021.
//

import Foundation
import RealmSwift

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    var safeRealm: Realm? {
        do {
            let realm = try Realm()
            return realm
        } catch {
            assertionFailure("Error")
        }
        return nil
    }
    
    private var place: Results<ShowPlaceObject>? {
        let object = safeRealm?.objects(ShowPlaceObject.self)
        return object
    }
    
    private init() {}
    
    func add(id: String) {
        do {
            try safeRealm?.write {
                let place = ShowPlaceObject()
                place.id = id
                safeRealm?.add(place)
            }
        } catch {
            assertionFailure("Error")
        }
    }
    
    func containsID(id: String) -> Bool {
        let object = safeRealm?.objects(ShowPlaceObject.self)
        let result = object?.contains(where: {$0.id == id}) ?? false
        return result
    }
    
    func remove(id: String) {
        do {
            try safeRealm?.write {
                let place = ShowPlaceObject()
                place.id = id
                if let result = safeRealm?.objects(ShowPlaceObject.self).filter("id=%@",place.id) {
                    safeRealm?.delete(result)
                }
            }
        } catch {
            assertionFailure("Error")
        }
    }
}



