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
    
    public static var shared: ARGModel = ARGModel()
    
    public var preferences: ARGModelPreferences? {
        willSet {
            assert(preferences == nil, "Model has been already initialized")
        }
    }
    
    public private(set) var tracker = ARGModelTracker()
    
    lazy var persistentContainer: NSPersistentContainer = {
        if self.preferences == nil {
            self.preferences = ARGModelPreferences()
        }

        let preferences: ARGModelPreferences! = self.preferences
        let processName = ProcessInfo.processInfo.processName
        let persistentContainer = NSPersistentContainer(name: processName, managedObjectModel: preferences.managedObjectModel!)

        persistentContainer.persistentStoreDescriptions = preferences.stores ?? [NSPersistentStoreDescription.userDataStoreDescription()]
        
        self.loadStores(persistentContainer)

        return persistentContainer
    }()
    
    public var viewContext: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    public func backgroundTask(_ block : @escaping (NSManagedObjectContext) -> Void) {
        self.persistentContainer.performBackgroundTask(block)
    }
    
    public func newBackgroundContext() -> NSManagedObjectContext {
        return self.persistentContainer.newBackgroundContext()
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
                print("Core Data storage has beed added: " + url.absoluteString)
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
}

extension NSPersistentStoreDescription {
    public class func appDataStoreDescription () -> NSPersistentStoreDescription {
        let url = URL(fileURLWithPath: applicationCacheDirectory(), isDirectory: true).appendingPathComponent(databaseFileName())
        let storeDescription = NSPersistentStoreDescription(url: url)
        storeDescription.type = NSSQLiteStoreType
        return storeDescription
    }
    
    public class func userDataStoreDescription () -> NSPersistentStoreDescription {
        let url = URL(fileURLWithPath: applicationSupportDirectory(), isDirectory: true).appendingPathComponent(databaseFileName())
        let storeDescription = NSPersistentStoreDescription(url: url)
        storeDescription.type = NSSQLiteStoreType
        return storeDescription
    }
    
    public class func transientStoreDescription () -> NSPersistentStoreDescription {
        let url = URL(string: "memory://storage")
        let storeDescription = NSPersistentStoreDescription(url: url!)
        storeDescription.type = NSInMemoryStoreType
        return storeDescription
    }
    
    
    private static func applicationSupportDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let appSupportDirectory = paths.first!
        
        if !FileManager.default.fileExists(atPath: appSupportDirectory) {
            try! FileManager.default.createDirectory(atPath: appSupportDirectory, withIntermediateDirectories: false, attributes: nil)
        }
        
        let fullDirectoryURL = URL(fileURLWithPath: appSupportDirectory, isDirectory: true).appendingPathComponent((Bundle.main.bundleIdentifier ?? Bundle(for: ARGModel.self).bundleIdentifier!))
        let fullDirectory = fullDirectoryURL.path
        
        if !FileManager.default.fileExists(atPath: fullDirectory) {
            try! FileManager.default.createDirectory(atPath: fullDirectory, withIntermediateDirectories: false, attributes: nil)
        }
        
        return fullDirectory
    }
    
    private static func applicationCacheDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let appSupportDirectory = paths.first!
        
        let fullDirectoryURL = URL(fileURLWithPath: appSupportDirectory, isDirectory: true).appendingPathComponent((Bundle.main.bundleIdentifier ?? Bundle(for: ARGModel.self).bundleIdentifier!))
        let fullDirectory = fullDirectoryURL.path
        
        if !FileManager.default.fileExists(atPath: fullDirectory) {
            try! FileManager.default.createDirectory(atPath: fullDirectory, withIntermediateDirectories: false, attributes: nil)
        }
        
        return fullDirectory
    }
    
    fileprivate static func databaseFileName() -> String {
        var appName = ProcessInfo.processInfo.processName
        
        return appName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) + ".sqlite"
    }
}

