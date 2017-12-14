//
//  ARGModelTests.swift
//  ARGModelTests
//
//  Created by Admin on 25/11/2017.
//  Copyright © 2017 Argentum. All rights reserved.
//

import XCTest
import CoreData
@testable import ARGModel

class ARGModelTests: XCTestCase {
    var model = ARGModel.shared
    
    override func setUp() {
        super.setUp()
        
        if model.preferences == nil {
            let preferences = ARGModelPreferences()
            
            preferences.entityMapping = { className in
                let suffixIndex = className.index(className.endIndex, offsetBy: -2)
                return String(className[..<suffixIndex])
            }
            
            preferences.managedObjectModel = ARGModelTestDataModel.testModel()
            
            preferences.stores = [NSPersistentStoreDescription.transientStoreDescription()]
            
            model.preferences = preferences
        }
        
    }
    
    override func tearDown() {
        model.viewContext.reset()
        super.tearDown()
    }
    
    func testCreateOnMainThread() {
        let testObject = model.viewContext.create(TestObjectMO.self)
        testObject.uid = "test"
        XCTAssert(testObject.managedObjectContext == model.viewContext)
        XCTAssert(model.viewContext.insertedObjects.count == 1)
    }
    
    func testCreateOnBackgroundThread() {
        let expect = expectation(description: "create")
       
        model.backgroundTask { context in
            let testObject = context.create(TestObjectMO.self)
            XCTAssert(testObject.managedObjectContext == context)
            XCTAssert(!Thread.isMainThread)
            XCTAssert(context.insertedObjects.count == 1)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("Creation timed out : \(error)")
            }
        }
    }
    
    func testFetchOnMainThread() {
        let testObject = model.viewContext.create(TestObjectMO.self)
        testObject.uid = "test"
        
        let objects = model.viewContext.fetchAllObjects(TestObjectMO.self)
        
        XCTAssert(objects?.count == 1)
    }
    
    func testFetchOnBackgroundThread() {
        let expect = expectation(description: "fetch")
        
        model.backgroundTask { context in
            let testObject = context.create(TestObjectMO.self)
            testObject.uid = "test"
            
            let objects = context.fetchAllObjects(TestObjectMO.self)
            
            XCTAssert(objects?.count == 1)
            
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("Fetch timed out : \(error)")
            }
        }
    }
    
    func testSaveOnMainThread() {
        let uid = UUID().uuidString
        let testObject = model.viewContext.create(TestObjectMO.self)
        testObject.uid = uid
        
        XCTAssert(model.viewContext.insertedObjects.count == 1)
        
        model.save(model.viewContext)
        
        XCTAssert(model.viewContext.insertedObjects.count == 0)
        
        model.viewContext.reset()
        
        let objects = model.viewContext.fetchObjects(type: TestObjectMO.self, predicate: NSPredicate(format: "uid = %@", uid))
        
        XCTAssert(objects?.count == 1)
    }
    
    func testSaveOnBackgroundThread() {
        let expect = expectation(description: "save")
        
        model.backgroundTask { context in
            let uid = UUID().uuidString
            let testObject = context.create(TestObjectMO.self)
            testObject.uid = uid
            
            XCTAssert(context.insertedObjects.count == 1)
            
            self.model.save(context)
            
            XCTAssert(context.insertedObjects.count == 0)
            
            let objectID = testObject.objectID
            
            DispatchQueue.main.async {
                let object = self.model.viewContext.objectForID(objectID, type: TestObjectMO.self)
                XCTAssert(object != nil)
                expect.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1)
    }
}
