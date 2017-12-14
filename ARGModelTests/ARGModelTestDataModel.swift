//
//  ARGModelTestDataModel.swift
//  ARGModelTests
//
//  Created by Fectum on 14/12/2017.
//  Copyright © 2017 Argentum. All rights reserved.
//

import Foundation
import CoreData

@objc (TestObjectMO)
class TestObjectMO: NSManagedObject {
    @NSManaged var uid: String?
}

class ARGModelTestDataModel {
     class func testModel() -> NSManagedObjectModel {
        let testModel = NSManagedObjectModel()
        let testEntity = NSEntityDescription()
        
        testEntity.name = "TestObject"
        testEntity.managedObjectClassName = "TestObjectMO"
        testEntity.isAbstract = false
        
        let nameAttribute = NSAttributeDescription()
        nameAttribute.name = "uid"
        nameAttribute.attributeType = NSAttributeType.stringAttributeType
        
        testEntity.properties = [nameAttribute]

        testModel.entities = [testEntity]
        
        return testModel
    }
}
