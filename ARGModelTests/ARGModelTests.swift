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
    
    func testBackgroundTask() {
        let expect = expectation(description: "bgTask")
        
        model.backgroundTask { context in
            XCTAssert(!Thread.isMainThread)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testNewBackgroundContext() {
        let context = model.newBackgroundContext()
        
        XCTAssert(context != model.viewContext)
        XCTAssert(context.concurrencyType == .privateQueueConcurrencyType)
    }
    
    func testSaveOnMainThread() {
        let uid = UUID().uuidString
        let testObject = model.viewContext.create(TestObjectMO.self)
        testObject.uid = uid
        
        model.save(model.viewContext)
        
        XCTAssert(model.viewContext.insertedObjects.count == 0)
        
        model.viewContext.reset()
        
        let objects = model.viewContext.fetchObjects(type: TestObjectMO.self, predicate: NSPredicate(format: "uid = %@", uid))
        
        XCTAssert(objects?.count == 1)
    }
    
    func testSaveOnBackgroundThread() {
        let expect = expectation(description: "save")
        
        model.backgroundTask { context in
            //arrange
            let uid = UUID().uuidString
            let testObject = context.create(TestObjectMO.self)
            testObject.uid = uid
            
            //act
            self.model.save(context)
            
            //assert
            XCTAssert(context.insertedObjects.count == 0)
            
            context.reset()
            
            let objects = context.fetchObjects(type: TestObjectMO.self, predicate: NSPredicate(format: "uid = %@", uid))
            
            XCTAssert(objects?.count == 1)
            
            expect.fulfill()
            
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testCreateContainer() {
        //arrange
        let expect = expectation(description: "container")
        
        //act
        let container = model.createContainer()

        //assert
        container.persistentStoreDescriptions = [NSPersistentStoreDescription.transientStoreDescription()]
        
        container.loadPersistentStores { (store, error) in
            XCTAssert(error == nil)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testCreateOnMainThread() {
        //arrange
        //act
        let testObject = model.viewContext.create(TestObjectMO.self)
        testObject.uid = "test"
        
        //assert
        XCTAssert(testObject.managedObjectContext == model.viewContext)
        XCTAssert(model.viewContext.insertedObjects.count == 1)
    }
    
    func testCreateOnBackgroundThread() {
        let expect = expectation(description: "create")
       
        model.backgroundTask { context in
            //arrange
            
            
            //act
            let testObject = context.create(TestObjectMO.self)
            
            //assert
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
    
    func testObjectID() {
        let expect = expectation(description: "save")
        
        model.backgroundTask { context in
            //arrange
            let uid = UUID().uuidString
            let testObject = context.create(TestObjectMO.self)
            testObject.uid = uid
            
            //act
            self.model.save(context)
            
            let objectID = testObject.objectID
            
            //assert
            DispatchQueue.main.async {
                let object = self.model.viewContext.objectForID(objectID, type: TestObjectMO.self)
                XCTAssert(object != nil)
                expect.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1)
    }

}
