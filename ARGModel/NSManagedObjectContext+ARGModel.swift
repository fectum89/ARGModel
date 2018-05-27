//
//  NSManagedObjectContext+ARGModel.swift
//  ARGModel
//
//  Created by Admin on 01/12/2017.
//  Copyright © 2017 Argentum. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    open func create<T: NSManagedObject>(_ type: T.Type) -> T {
        let components = entityName(for: type).components(separatedBy: ".")
        let object = NSEntityDescription.insertNewObject(forEntityName: components.last!, into: self) as! T
        object.assignToConfiguration("PF_DEFAULT_CONFIGURATION_NAME");
        object.onCreate()
        return object
    }
    
    public func fetchAllObjects<T: NSManagedObject>(_ type: T.Type) -> [T]? {
        return self.fetchObjects(type: type, predicate: nil)
    }
    
    public func fetchObjects<T: NSManagedObject>(type: T.Type, _ format: String, _ args: CVarArg...) -> [T]? {
        let predicate = NSPredicate(format: format, arguments: getVaList(args))
        return fetchObjects(type: type, predicate: predicate)
    }
    
    public func fetchObjects<T: NSManagedObject>(type: T.Type, predicate: NSPredicate?) -> [T]? {
        let request = NSFetchRequest<T>(entityName: entityName(for: type))
        
        request.predicate = predicate
        
        do {
            return try self.fetch(request)
        } catch {
            print(error)
        }

        return []
    }
    
    public func countOfObjects<T: NSManagedObject>(type: T.Type) -> Int {
        //let entityName = ARGModel.shared.preferences?.entityMapping?(NSStringFromClass(type)) ?? NSStringFromClass(type)
        let request = NSFetchRequest<T>(entityName: entityName(for: type))
        
        do {
            return try self.count(for: request)
        } catch {
            print(error)
        }
        
        return 0
    }
    
    public func entityName<T: NSManagedObject>(for type: T.Type) -> String {
        let entityName = ARGModel.shared.preferences?.entityMapping?(NSStringFromClass(type)) ?? NSStringFromClass(type)
        return entityName
    }
    
//    public func fetchObjects<T: NSManagedObject>(type: T.Type, _ configureRequestClosure: (NSFetchRequest<T>) -> ()) -> [T]? {
//        let entityName = ARGModel.shared.preferences?.entityMapping?(NSStringFromClass(type)) ?? NSStringFromClass(type)
//        let request = NSFetchRequest<T>(entityName: entityName)
//
//        configureRequestClosure(request)
//
//        //request.predicate = predicate
//
//        do {
//            return try self.fetch(request)
//        } catch {
//            print(error)
//        }
//
//        return []
//    }
    
    public func objectForID<T: NSManagedObject>(_ objectId: NSManagedObjectID, type: T.Type) -> T? {
        do {
            return try self.existingObject(with: objectId) as? T
        } catch {
            print(error)
        }
        
        return nil
    }
    
    public func objectsWith<T: Sequence>(ids: T) -> [NSManagedObject] where T.Element: NSManagedObjectID {
        return ids.map { return objectForID($0, type: NSManagedObject.self)! }
    }
    
//    public func objectsWith<T: Sequence, U: NSManagedObject>(ids: T, type: U.Type) -> [U] where T.Element: NSManagedObjectID {
//        return ids.map { return objectForID($0, type: type) }
//    }
    
}

//ObjC support
@available(swift, obsoleted: 1.0)
public extension NSManagedObjectContext {
    
    @objc
    public func create(type: AnyClass) -> Any {
        return create(type as! NSManagedObject.Type)
    }
    
    @objc
    public func fetchAllObjects(of type: AnyClass) -> [Any]? {
        return self.fetchObjects(type: type as! NSManagedObject.Type, predicate: nil)
    }
    
    @objc
    public func fetchObjects(of type: AnyClass, predicate: NSPredicate) -> [Any]? {
        return self.fetchObjects(type: type as! NSManagedObject.Type, predicate: predicate)
    }
    
    @objc
    public func count(of: AnyClass) -> Int {
        return self.countOfObjects(type: of as! NSManagedObject.Type)
    }
    
//    @objc
//    public func fetchObjects(of type: AnyClass, configureBlock configureRequestClosure: (NSFetchRequest<NSManagedObject>) -> ()) -> [Any]? {
//        return self.fetchObjects(type: type as! NSManagedObject.Type, configureRequestClosure)
//    }
    
    @objc public func objects(ids: [NSManagedObjectID]) -> [NSManagedObject] {
        return objectsWith(ids: ids)
    }
    
//    @objc public func find(objectId: NSManagedObjectID?) -> Any? {
//        if let objectId = objectId {
//            return try? self.existingObject(with: objectId)
//        }
//        return nil
//    }
//
//    @objc public func findFirst(_ type: AnyClass, key: String, value: Any) -> Any? {
//        let predicate = NSPredicate(format: "\(key) == %@", argumentArray: [value])
//        return findFirst(type: type as! NSManagedObject.Type, predicate: predicate)
//    }
//
//    @objc public func find(_ type: AnyClass, key: String, value: Any) -> [Any] {
//        let predicate = NSPredicate(format: "\(key) == %@", argumentArray: [value])
//        return find(type: type as! NSManagedObject.Type, predicate: predicate)
//    }
//
//    @objc public func findFirst(_ type: AnyClass, predicate: NSPredicate) -> Any? {
//        return findFirst(type: type as! NSManagedObject.Type, predicate: predicate)
//    }
//

//
//    @objc public func objects(ids: [NSManagedObjectID]) -> [NSManagedObject] {
//        return objectsWith(ids: ids)
//    }
//

}

