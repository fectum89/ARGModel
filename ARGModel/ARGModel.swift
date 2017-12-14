//
//  ARGModel.swift
//  ARGModel
//
//  Created by Admin on 26/11/2017.
//  Copyright © 2017 Argentum. All rights reserved.
//

import UIKit
import CoreData

public class ARGModelPreferences {
    
    public var stores: [NSPersistentStoreDescription]?
    
    public var entityMapping: ((String) -> String)?
    
    public var managedObjectModel: NSManagedObjectModel?
    
    public init() {
        let bundle = Bundle.main
        self.managedObjectModel = NSManagedObjectModel.mergedModel(from: [bundle])
    }
    
}

public class ARGModel {
    
    public static let shared = ARGModel(preferences: ARGModelPreferences())
    
    public private(set) var preferences: ARGModelPreferences
    
    public private(set) var viewContext: NSManagedObjectContext
    
    public private(set) var tracker: ARGModelTracker
    
    var persistentContainer: NSPersistentContainer
    
    init(preferences: ARGModelPreferences?) {
        self.preferences = preferences ?? ARGModelPreferences()
        tracker = ARGModelTracker()
        
        let processName = ProcessInfo.processInfo.processName
        self.persistentContainer = NSPersistentContainer(name: processName, managedObjectModel: self.preferences.managedObjectModel!)
        
        if self.preferences .stores != nil {
            self.persistentContainer.persistentStoreDescriptions = self.preferences.stores!
        }
        
        self.loadStores(self.persistentContainer)
        
        self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        
        viewContext = self.persistentContainer.viewContext
    }
    
    public class func configure(preferences: ARGModelPreferences) {
        //assert(self.shared.preferences == nil, "Model has been already initialized")
        self.shared.preferences = preferences
    }

    public func backgroundTask(_ block : @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
    
    public func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    public func save(_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func loadStores(_ container: NSPersistentContainer) {
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
            let url: URL? = storeDescription.url
            
            if let url = url {
                print("Core Data storage has beed added: " + url.path)
            }
        })
    }

//    lazy var persistentContainer: NSPersistentContainer = {
//        let preferences = self.preferences ?? ARGModelPreferences()
//        let processName = ProcessInfo.processInfo.processName
//        let container = NSPersistentContainer(name: processName, managedObjectModel: preferences.managedObjectModel!)
//
//        if self.preferences?.stores != nil {
//            container.persistentStoreDescriptions = self.preferences!.stores!
//        }
//
//        self.loadStores(container)
//
//        container.viewContext.automaticallyMergesChangesFromParent = true
//
//        return container
//    }()
    
    public func addListener(_ listener: AnyObject, forClasses classes: [AnyClass]) {
        for klass in classes {
            print(NSStringFromClass(klass))
        }
    }
    
    public func addListener(_ listener: AnyObject, forObject object: NSManagedObject) {
        
    }
}

extension NSPersistentStoreDescription {
//    public class func appDataStoreDescription () -> Self {
//        
//    }
}

