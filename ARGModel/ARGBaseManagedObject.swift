//
//  ARGBaseManagedObject.swift
//  ARGModel
//
//  Created by Admin on 27/11/2017.
//  Copyright © 2017 Argentum. All rights reserved.
//

import Foundation
import CoreData

open class ARGBaseManagedObject: NSManagedObject {
    
    open class func create(in context: NSManagedObjectContext) -> NSManagedObject? {
        var object: NSManagedObject? = nil
        
        context.performAndWait {
            object = NSEntityDescription.insertNewObject(forEntityName: self.entityName(), into: context)
        }
        
        return object
    }
    
    open class func entityName() -> String {
        let fullName: String = NSStringFromClass(self)
        return fullName.components(separatedBy: ".").last!
    }
    
    public class func fetchAllObjects(in context: NSManagedObjectContext) -> Array<NSManagedObject>? {
        return self.fetchObjects(in: context, predicate: nil)
    }
    
    public class func fetchObjects(in context: NSManagedObjectContext, predicate: NSPredicate?) -> Array<NSManagedObject>? {
        let request: NSFetchRequest = NSFetchRequest<NSManagedObject>(entityName: self.entityName())
        request.predicate = predicate
        
        var result: [NSManagedObject]?
        
        do {
            try result = context.fetch(request)
        } catch {
            print(error)
        }
        
        return result
    }
    
    public class func objectForID(_ objectID: NSManagedObjectID, in context: NSManagedObjectContext) -> NSManagedObject? {
        do {
            return try context.existingObject(with: objectID)
        } catch {
            print(error)
            return nil
        }
    }
    
}
