//
//  ARGModelTrackerTests.swift
//  ARGModelTests
//
//  Created by Admin on 06/12/2017.
//  Copyright © 2017 Argentum. All rights reserved.
//

import XCTest
@testable import ARGModel

class ARGModelTrackerTests: XCTestCase {
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
            model.preferences = preferences
            
            model.addStores([NSPersistentStoreDescription.transientStoreDescription()])
        }
    }
    
    override func tearDown() {
        self.stopWatching()
    }
    
    func testAddObserver() {
        //arrange
        let observer1 = NSObject()
        let observer2 = NSObject()
        
        //act
        model.tracker.addObserver(observer1, for: ["key1", "key2"]) {}
        model.tracker.addObserver(observer2, for: ["key1"]) {}
        
        //assert
        let observers1 = model.tracker.observersDictionary["key1"]
        let observers2 = model.tracker.observersDictionary["key2"]
        
        XCTAssert(observers1?.count == 2)
        XCTAssert(observers2?.count == 1)
        
        XCTAssert(observers1?[0].object == observer1 && observers1?[1].object == observer2)
        XCTAssert(observers2?[0].object == observer1)
    }
    
    func testRemoveObserver() {
        //arrange
        let object = NSObject()
        model.tracker.addObserver(object, for: ["key1"]) {}
        
        //act
        model.tracker.removeObserver(object)
        
        //assert
        XCTAssert(model.tracker.observersDictionary["key1"]?.count == 0)
    }
    
    func testPostNotifications() {
        var invocationCount: Int = 0
        let observer = NSObject()
        let expect = expectation(description: "observer")
        
        expect.assertForOverFulfill = false
        
        model.tracker.addObserver(observer, for: ["key1", "key2"]) {
            invocationCount = invocationCount + 1
            
            XCTAssert(invocationCount == 1)
            
            expect.fulfill()
        }
        
        model.tracker.postNotifications(for: ["key1", "key2"])
        
        waitForExpectations(timeout: 1)
    }
    
    func testImplicitObserving () {
        //arrange
        let expect = expectation(description: "observing")
        
        self.watch(for: [TestObjectMO.self]) {
            expect.fulfill()
        }
        
        //act
        model.backgroundTask { (context) in
            let _ = context.create(TestObjectMO.self)
            self.model.save(context)
        }
        
        //assert
        waitForExpectations(timeout: 1)
    }
    
}
