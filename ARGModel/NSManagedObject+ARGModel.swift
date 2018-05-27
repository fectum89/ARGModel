//
//  NSManagedObject+ARGModel.swift
//  ARGModel
//
//  Created by Admin on 15/04/2018.
//  Copyright © 2018 Argentum. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    @objc open func onCreate() {
        //override it if needed
    }
    
    @objc
    public func assignToConfiguration(_ configuration: String?) {
        let store = ARGModel.shared.store(for: configuration)
        self.managedObjectContext?.assign(self, to: store!)
    }
    
    @objc public func delete() {
        self.managedObjectContext?.delete(self)
    }
    
    @objc public func isObjectDeleted() -> Bool {
        return self.managedObjectContext == nil || self.isDeleted
    }
    
    @objc public func permanentObjectID() -> NSManagedObjectID {
        var objectId = self.objectID
        
        if objectId.isTemporaryID {
            try? managedObjectContext?.obtainPermanentIDs(for: [self])
            objectId = self.objectID
        }
        return objectId
    }
    
    public class func idsWith<T: Sequence>(objects: T) -> [NSManagedObjectID] where T.Element: NSManagedObject {
        return objects.map { return $0.permanentObjectID() }
    }
    
    public class func uriWith<T: Sequence>(ids: T) -> [URL] where T.Element: NSManagedObjectID {
        return ids.map { return $0.uriRepresentation() }
    }    
}
