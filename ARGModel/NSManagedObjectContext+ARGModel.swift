//
//  NSManagedObjectContext+ARGModel.swift
//  ARGModel
//
//  Created by Admin on 01/12/2017.
//  Copyright © 2017 Argentum. All rights reserved.
//

import Foundation

extension NSManagedObjectContext {
    
    open func create<T: NSManagedObject>(_ type: T.Type) -> T {
        let entityName = ARGModel.sharedInstance.configuration?.entityMapping?(NSStringFromClass(type)) ?? NSStringFromClass(type)
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: self) as! T
    }
    
    public func fetchAllObjects<T: NSManagedObject>(_ type: T.Type) -> [T]? {
        return self.fetchObjects(type: type, predicate: nil)
    }
    
    public func fetchObjects<T: NSManagedObject>(type: T.Type, predicate: NSPredicate?) -> [T]? {
        let entityName = ARGModel.sharedInstance.configuration?.entityMapping?(NSStringFromClass(type)) ?? NSStringFromClass(type)
        let request = NSFetchRequest<T>(entityName: entityName)

        request.predicate = predicate
        
        do {
            return try self.fetch(request)
        } catch {
            print(error)
        }

        return []
    }
    
    public func objectForID<T: NSManagedObject>(_ objectId: NSManagedObjectID, type: T.Type) -> T? {
        do {
            return try self.existingObject(with: objectId) as? T
        } catch {
            print(error)
        }
        
        return nil
    }
}
