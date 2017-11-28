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
    
}
