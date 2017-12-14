//
//  ARGModelTracker.swift
//  ARGModel
//
//  Created by Admin on 03/12/2017.
//  Copyright © 2017 Argentum. All rights reserved.
//

import UIKit

extension NSObject {
    public func watch(for classes: [NSManagedObject.Type], _ closure: @escaping () -> ()) {
        let keys = classes.map { (type) -> String in
            return NSStringFromClass(type)
        }
        
        ARGModel.shared.tracker.addObserver(self, closure: closure, for: keys)
    }
    
    public func watch(for object: NSManagedObject, _ closure: @escaping () -> ()) {
        ARGModel.shared.tracker.addObserver(self, closure: closure, for: [object.objectID.uriRepresentation().absoluteString])
    }
    
    public func stopWatching () {
        ARGModel.shared.tracker.removeObserver(self)
    }
}

class ARGObserver : Equatable {
    var object: NSObject?
    var closure: () -> ()
    
    init(object: NSObject, closure: @escaping () -> ()) {
        self.object = object
        self.closure = closure
    }
    
    static func == (lhs: ARGObserver, rhs: ARGObserver) -> Bool {
        return lhs.object == rhs.object && String(describing: lhs.closure) == String(describing: rhs.closure)
    }
}

public class ARGModelTracker {
    var observersDictionary: [String : [ARGObserver]] = [:]
    
    public init() {
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidChange(notification:)), name: Notification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
    }
    
    @objc func contextDidChange(notification: NSNotification) {
        let context = notification.object as? NSManagedObjectContext
        
        if context?.concurrencyType == NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType {
            let inserted = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>
            let updated = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>
            let deleted = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>
            
            
        }
    }
    
    public func addObserver(_ object: NSObject, closure: @escaping () -> (), for keys: [String]) {
        assert(Thread.isMainThread, "This API could be used only on main thread")
        let observer = ARGObserver(object: object, closure: closure)
        
        for key in keys {
            var observers = observersDictionary[key] ?? []
            observers.append(observer)
            observersDictionary[key] = observers
        }
    }
    
    public func removeObserver(_ object: NSObject) {
        for (_, var observers) in self.observersDictionary {
            for observer in observers {
                if observer.object == object {
                    observers.remove(at: observers.index(of: observer)!)
                }
            }
        }
    }
    
    public func postNotifications(for keys: [String]) {
        DispatchQueue.main.async {
            var notifiedObservers = [ARGObserver]()
            
            for key in keys {
                if var observers = self.observersDictionary[key] {
                    for observer in observers {
                        if observer.object == nil {
                            observers.remove(at: observers.index(of: observer)!)
                        } else if !notifiedObservers.contains(observer) {
                            observer.closure()
                            notifiedObservers.append(observer)
                        }
                    }
                }
            }
        }
    }
}
