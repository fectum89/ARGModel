//
//  ARGModel.swift
//  ARGModel
//
//  Created by Admin on 26/11/2017.
//  Copyright © 2017 Argentum. All rights reserved.
//

import UIKit
import CoreData

@objc public class ARGModelPreferences: NSObject, NSCopying {
    
    @objc public var stores: [NSPersistentStoreDescription]?
    
    @objc public var entityMapping: ((String) -> String)?
    
    @objc public var managedObjectModel: NSManagedObjectModel?
    
//    override public init() {
//        //let bundle = Bundle.main
//        //self.managedObjectModel = NSManagedObjectModel.mergedModel(from: [bundle])
//    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let preferences = ARGModelPreferences()
        preferences.stores = self.stores
        preferences.entityMapping = self.entityMapping
        preferences.managedObjectModel = self.managedObjectModel
        return preferences
    }
    
}

@objc public class ARGModel: NSObject {
    
    @objc public static var shared: ARGModel = ARGModel()
    
    var _preferences: ARGModelPreferences?
    @objc public var preferences: ARGModelPreferences? {
        set {
            assert(preferences == nil, "Model has been already initialized")
            _preferences = newValue?.copy() as? ARGModelPreferences
        }
        get {
            return _preferences?.copy() as? ARGModelPreferences
        }
    }
    
    @objc public private(set) var tracker = ARGModelTracker()
    
    @objc public var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    @objc public var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        return persistentContainer.persistentStoreCoordinator
    }
    
    
    @objc public func backgroundTask(_ block : @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
    
    @objc public func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    @objc public func save(_ context: NSManagedObjectContext = ARGModel.shared.viewContext) {
        if context.hasChanges {
            do {
                //context.mergePolicy = NSOverwriteMergePolicy
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    public func store(for configuration: String?) -> NSPersistentStore? {
        for store in self.persistentStoreCoordinator.persistentStores {
            if store.configurationName == configuration {
                return store
            }
        }
        
        return nil
    }
    
    public func addStore(_ storeDescription: NSPersistentStoreDescription, completion: @escaping (Error) -> ()) {
        
    }
    
    public func removeStore(_ storeDescription: NSPersistentStoreDescription, completion: @escaping (Error) -> ()) {
        
    }
    
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = createContainer()

        container.loadPersistentStores(completionHandler: { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
            let url: URL? = storeDescription.url
            
            if let url = url {
                print("Core Data storage has beed added: " + url.absoluteString)
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        return container
    }()
    
    func createContainer() -> NSPersistentContainer {
        if self.preferences == nil {
            self.preferences = ARGModelPreferences()
        }
        
        let preferences: ARGModelPreferences! = self.preferences
        let processName = ProcessInfo.processInfo.processName
        
        if preferences.managedObjectModel == nil {
            let bundle = Bundle.main
            preferences.managedObjectModel = NSManagedObjectModel.mergedModel(from: [bundle])
        }
        
        let persistentContainer = NSPersistentContainer(name: processName, managedObjectModel: preferences.managedObjectModel!)
        
        persistentContainer.persistentStoreDescriptions = preferences.stores ?? [NSPersistentStoreDescription.userDataStoreDescription()]
        
        return persistentContainer
    }
}

@objc
extension NSPersistentStoreDescription {
    @objc
    public class func appDataStoreDescription () -> NSPersistentStoreDescription {
        let url = URL(fileURLWithPath: applicationCacheDirectory(), isDirectory: true).appendingPathComponent(databaseFileName())
        let storeDescription = NSPersistentStoreDescription(url: url)
        storeDescription.type = NSSQLiteStoreType
        return storeDescription
    }
    
    @objc
    public class func userDataStoreDescription () -> NSPersistentStoreDescription {
        let url = URL(fileURLWithPath: applicationSupportDirectory(), isDirectory: true).appendingPathComponent(databaseFileName())
        let storeDescription = NSPersistentStoreDescription(url: url)
        storeDescription.type = NSSQLiteStoreType
        return storeDescription
    }
    
    @objc
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
        let appName = ProcessInfo.processInfo.processName
        return appName.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) + ".sqlite"
    }
}

