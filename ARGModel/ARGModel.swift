//
//  ARGModel.swift
//  ARGModel
//
//  Created by Admin on 26/11/2017.
//  Copyright © 2017 Argentum. All rights reserved.
//

import UIKit
import CoreData

public class ARGModelConfiguration {
    public var stores: [NSPersistentStoreDescription]?
    public var entityMapping: ((String) -> String)?
    public var managedObjectModel: NSManagedObjectModel?
    
    public init () {
        
    }
}

public class ARGModel {
    
    public static let sharedInstance = ARGModel()
    
    public var configuration: ARGModelConfiguration?
    
    public static let viewContext = ARGModel.sharedInstance.persistentContainer.viewContext
    
    public class func setup(configuration: ARGModelConfiguration) {
        assert(self.sharedInstance.configuration == nil, "Model has been already initialized")
        self.sharedInstance.configuration = configuration
    }
    
    public class func backgroundTask(_ block : @escaping (NSManagedObjectContext) -> Void) {
        self.sharedInstance.persistentContainer.performBackgroundTask(block)
    }
    
    public class func newBackgroundContext() -> NSManagedObjectContext {
        return self.sharedInstance.persistentContainer.newBackgroundContext()
    }
    
    public class func save(_ context: NSManagedObjectContext) {
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

    lazy var persistentContainer: NSPersistentContainer = {
        let configuration = self.configuration ?? ARGModelConfiguration()
        let bundle = Bundle.main
        let mom = configuration.managedObjectModel ?? NSManagedObjectModel.mergedModel(from: [bundle])
        let processName = ProcessInfo.processInfo.processName
        let container = NSPersistentContainer(name: processName, managedObjectModel: mom!)
        
        if self.configuration?.stores != nil {
            container.persistentStoreDescriptions = self.configuration!.stores!
        }
        
        self.loadStores(container)
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
    public class func addListener(_ listener: AnyObject, forClasses classes: [AnyClass]) {
        for klass in classes {
            print(NSStringFromClass(klass))
        }
    }
    
    public class func addListener(_ listener: AnyObject, forObject object: NSManagedObject) {
        
    }
}

extension NSPersistentStoreDescription {
//    public class func appDataStoreDescription () -> Self {
//        
//    }
}

extension NSObject {
    public func watch(for classes: [NSManagedObject.Type]) {
        for klass in classes {
            print(NSStringFromClass(klass))
        }
    }
    
    public func watch(for object: NSManagedObject) {
        
    }
}
