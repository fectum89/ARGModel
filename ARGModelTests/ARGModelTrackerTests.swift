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
    var tracker: ARGModelTracker!
    var object = NSObject()
    
    override func setUp() {
        super.setUp()
        self.tracker = ARGModelTracker()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExplicitObserving() {
        var invocationCount: Int = 0
        
        let expect = expectation(description: "observer")
        
        expect.assertForOverFulfill = false
        
        self.tracker.addObserver(self.object, closure: {
            invocationCount = invocationCount + 1
            
            XCTAssert(invocationCount == 1)
            
            expect.fulfill()
        }, for: ["key1", "key2"])
        
        self.tracker.postNotifications(for: ["key1", "key2"])
        
        waitForExpectations(timeout: 1) { (error) in
            if let error = error {
                XCTFail("Observing timed out : \(error)")
            }
        }
    }
    
    func testImplicitObserving () {
        let preferences = ARGModelPreferences()
        
        preferences.entityMapping = { (className) in
            let suffixIndex = className.index(className.endIndex, offsetBy: -2)
            return String(className[..<suffixIndex])
        }
        
        ARGModel.configure(preferences: preferences)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
