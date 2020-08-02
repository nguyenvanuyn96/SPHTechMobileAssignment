//
//  DatabaseService.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 8/2/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import RxRealm

protocol MobileDataUsageDatabaseServiceProtocol {
    func getMobileDataUsage() -> [Record]
    func saveMobileDataUsage(records: [Record])
}

class DatabaseService {
    public init() {
        self.updateRealm()
    }
    
    private var realm: Realm {
        do {
            let realm = try Realm()
            let folderPath = realm.configuration.fileURL!.deletingLastPathComponent().path
            print("folderPath : \(folderPath)")
            return realm
        } catch let error {
            fatalError(String(describing: error))
        }
    }
    
    public func updateRealm() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 2,
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
                
        },
            deleteRealmIfMigrationNeeded: true
        )
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
    
    public func objects<Element: Object>(_ type: Element.Type) -> Results<Element> {
        return realm.objects(type)
    }
    
    public func objects<Element: Object>(_ type: Element.Type, filter predicate: NSPredicate) -> Results<Element> {
        return realm.objects(type).filter(predicate)
    }
    
    public func observableObjects<T: Object>(type: T.Type, sortByKeyPath keyPath: String, ascending: Bool) -> Observable<Results<T>> {
        return Observable.collection(from: realm.objects(T.self).sorted(byKeyPath: keyPath, ascending: ascending)).asObservable()
    }
    
    public func observableObjects<T: Object>(type: T.Type) -> Observable<Results<T>> {
        return Observable.collection(from: realm.objects(T.self)).asObservable()
    }
    
    public func observableObjects<T: Object>(type: T.Type, filter predicate: NSPredicate) -> Observable<Results<T>> {
        return Observable.collection(from: realm.objects(T.self).filter(predicate)).asObservable()
    }
    
    public func read<T>(_ type : T.Type) -> [T] where T : Object {
        return self.realm.objects(type).map{$0.detached()}
    }
    
    
    public func create(object: Object, updatePolicy: Realm.UpdatePolicy = .error) {
        tryOrLogError { realm.add(object, update: updatePolicy) }
    }
    
    public func createWithTransaction(objects: [Object], updatePolicy: Realm.UpdatePolicy = .error) {
        tryOrLogError {
            try realm.safeWrite {
                realm.add(objects, update: updatePolicy)
            }
        }
    }
    
    public func create(objects: [Object], updatePolicy: Realm.UpdatePolicy = .error) {
        tryOrLogError { realm.add(objects, update: updatePolicy) }
    }
    
    public func create<T: Object>(_ type: T.Type, value: Any, updatePolicy: Realm.UpdatePolicy = .error) {
        tryOrLogError { realm.create(T.self, value: value, update: updatePolicy) }
    }
    
    public func delete<T: RealmSwift.Object>(object: T) {
        tryOrLogError { realm.delete(object) }
    }
    
    public func delete<Element: Object>(objects: Results<Element>) {
        
        tryOrLogError { realm.delete(objects) }
    }
    
    public func delete<T: Object>(type: T.Type,keys : [Any]) {
        for key in keys {
            if let object = realm.object(ofType: type, forPrimaryKey: key){
                let ref = ThreadSafeReference.init(to: object)
                guard let  objectRef = realm.resolve(ref) , objectRef.isInvalidated ==  false  else {return}
                tryOrLogError {
                    try realm.safeWrite {
                        realm.delete(objectRef)
                    }
                }
            }
        }
    }
    
    public func deleteAll() {
        tryOrLogError { realm.deleteAll() }
    }
    
    private func tryOrLogError(_ block: (() throws -> Void)) {
        do {
            try realm.write {
                try block()
            }
        } catch {
            print(error)
        }
    }
}

public extension Results {
    
    func toArray<T>(ofType: T.Type) -> [T] {
        return self.compactMap {$0 as? T}
    }
    
}

public extension RealmSwift.List {
    
    func toArray<T>(ofType: T.Type) -> [T] {
        return self.compactMap {$0 as? T}
    }
    
}

// MARK: - DetachableObject

public protocol DetachableObject: AnyObject {
    
    func detached() -> Self
    
}

extension Object: DetachableObject {
    public func detached() -> Self {
        let detached = type(of: self).init()
        
        for property in objectSchema.properties {
            guard let value = value(forKey: property.name) else { continue }
            
            if let detachable = value as? DetachableObject {
                detached.setValue(detachable.detached(), forKey: property.name)
            } else {
                detached.setValue(value, forKey: property.name)
            }
        }
        return detached
    }
    
}

extension List: DetachableObject {
    public func detached() -> List<Element> {
        let result = List<Element>()
        forEach {
            if let e = ($0 as? Object)?.detached() {
                result.append(e as! Element)
            }
        }
        return result
    }
}

public extension Realm {
    func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
}

extension DatabaseService: MobileDataUsageDatabaseServiceProtocol {
    func getMobileDataUsage() -> [Record] {
        return self.read(Record.self)
    }
    
    func saveMobileDataUsage(records: [Record]) {
        self.create(objects: records, updatePolicy: .all)
    }
}

