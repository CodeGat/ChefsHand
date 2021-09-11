//
//  RealmManager.swift
//  ChefsHand
//
//  Created by Tommy Gatti on 10/9/21.
//

import Foundation
import RealmSwift

class RealmManager {
    static let shared = RealmManager()
    private var realm: Realm?
    
    private init(){}
    
    func loadRealm(){
        self.realm = try! Realm()
    }
    
    func create(_ object: Object) {
        try! realm?.write {
            realm?.add(object)
        }
    }
    
    func read<T>(_ type: T.Type) -> Results<T>? where T: Object  {
        return read(type, filter: nil)
    }
    
    func read<T>(_ type: T.Type, filter: String?) -> Results<T>? where T: Object {
        let objects = realm?.objects(type)
        if filter != nil {
            return objects?.filter(filter!)
        } else {
            return objects
        }
    }
    
    func read<T>(_ type: T.Type, at index: Int) -> T? where T: Object {
        let objects = realm?.objects(type)
        
        return objects?[index]
    }
    
    func update<T>(_ block: () throws -> Results<T>) where T: Object {
        try! realm?.write(block)
    }
    
    func delete(_ object: Object){
        try! realm?.write {
            realm?.delete(object)
        }
    }
    
    func delete(_ type: Object.Type, at index: Int) {
        guard let objectToDelete: Object = realm?.objects(type)[index] else {fatalError("Failed to get object to delete")}
        try! realm?.write{
            realm?.delete(objectToDelete)
        }
    }
}
