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
    
    func read(_ type: Object.Type, filter: String?) -> Results<Object>? {
        let objects = realm?.objects(type)
        if filter != nil {
            return objects?.filter(filter!)
        } else {
            return objects
        }
    }
    
    func update(_ block: () throws -> Results<Object>){
        try! realm?.write(block)
    }
    
    func delete(_ object: Object){
        try! realm?.write {
            realm?.delete(object)
        }
    }
}
