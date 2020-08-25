//
//  ARGModelTracker.swift
//  ARGModel
//
//  Created by Admin on 03/12/2017.
//  Copyright © 2017 Argentum. All rights reserved.
//

import Foundation
import CoreData

public extension NSObject {
    
    @objc
    func watch(for classes: [NSManagedObject.Type], _ closure: @escaping () -> ()) {
        let keys = classes.map { (type) -> String in
            return NSStringFromClass(type)
        }
        
        ARGModel.shared.tracker.addObserver(self, for: keys, closure: closure)
    }
    
    func watch(for object: NSManagedObject, _ closure: @escaping () -> ()) {
        ARGModel.shared.tracker.addObserver(self, for: [object.objectID.uriRepresentation().absoluteString], closure: closure)
    }
    
    @objc
    func stopWatching () {
        ARGModel.shared.tracker.removeObserver(self)
    }
}

//ObjC support
@available(swift, obsoleted: 1.0)
public extension NSObject {
    @objc
    func watchForObject(_ object: NSManagedObject, _ closure: @escaping () -> ()) {
        ARGModel.shared.tracker.addObserver(self, for: [object.objectID.uriRepresentation().absoluteString], closure: closure)
    }
}

public
class ARGObserver : Equatable {
    weak var object: NSObject?
    var closure: () -> ()
    var info: String?
    
    init(object: NSObject, closure: @escaping () -> ()) {
        self.object = object
        self.closure = closure
        self.info = object.description
    }
    
    func debugDescription() {
        print(info ?? "")
    }
    
    public
    static func == (lhs: ARGObserver, rhs: ARGObserver) -> Bool {
        return lhs.object == rhs.object && String(describing: lhs.closure) == String(describing: rhs.closure)
    }
}

@objc public class ARGModelTracker: NSObject {
    public var observersDictionary: [String : [ARGObserver]] = [:]
    
    override public init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidChange(notification:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
    }
    
    @objc func contextDidChange(notification: NSNotification) {
        let context = notification.object as? NSManagedObjectContext
        
        if context?.concurrencyType == NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType {
            let inserted = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>
            let updated = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>
            let deleted = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>
            
            var changesEntities = [String]()
            
            if inserted != nil {
                for object in inserted! {
                    let typeName = NSStringFromClass(type(of: object))
                    
                    if !changesEntities.contains(typeName) {
                        changesEntities.append(typeName)
                    }
                }
            }
            
            if updated != nil {
                for object in updated! {
                    let typeName = NSStringFromClass(type(of: object))
                    
                    if !changesEntities.contains(typeName) {
                        changesEntities.append(typeName)
                    }
                }
            }
            
            if deleted != nil {
                for object in deleted! {
                    let typeName = NSStringFromClass(type(of: object))
                    
                    if !changesEntities.contains(typeName) {
                        changesEntities.append(typeName)
                    }
                }
            }
            
            if changesEntities.count > 0 {
                DispatchQueue.main.async {
                    ARGModel.shared.tracker.postNotifications(for: changesEntities)
                }
            }
        }
    }
    
    @objc public func addObserver(_ object: NSObject, for keys: [String], closure: @escaping () -> ()) {
        assert(Thread.isMainThread, "This API could be used only on main thread")
        let observer = ARGObserver(object: object, closure: closure)
        
        for key in keys {
            var observers = observersDictionary[key] ?? []
            observers.append(observer)
            print("[ARGModel] Observer for \(observer.info ?? "unknown") added")
            
            for observerForDelete in observers {
                if observerForDelete.object == nil {
                    observers.remove(at: observers.firstIndex(of: observerForDelete)!)
                    print("[ARGModel] Observer for \(observerForDelete.info ?? "unknown") removed automatically")
                }
            }
            
            observersDictionary[key] = observers
        }
    }
    
    @objc public func removeObserver(_ object: NSObject) {
        for (key, var observers) in observersDictionary {
            for observer in observers {
                if observer.object == object {
                    observers.remove(at: observers.firstIndex(of: observer)!)
                    print("[ARGModel] Observer for \(observer.info ?? "unknown") removed manually")
                    observersDictionary[key] = observers
                }
            }
        }
    }
    
    @objc public func postNotifications(for keys: [String]) {
        DispatchQueue.main.async {
            var notifiedObservers = [ARGObserver]()
            
            for key in keys {
                if var observers = self.observersDictionary[key] {
                    for observer in observers {
                        if observer.object == nil {
                            observers.remove(at: observers.firstIndex(of: observer)!)
                            print("[ARGModel] Observer for \(observer.info ?? "unknown") removed automatically")
                        } else if !notifiedObservers.contains(observer) {
                            DispatchQueue.main.async {
                                observer.closure()
                            }
                            
                            notifiedObservers.append(observer)
                        }
                    }
                    
                    self.observersDictionary[key] = observers
                }
            }
        }
    }
}
