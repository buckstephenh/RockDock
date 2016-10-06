//
//  RockDockTests.swift
//  RockDockTests
//
//  Created by Stephen Buck on 8/27/16.
//  Copyright © 2016 Stephen Buck. All rights reserved.
//

import XCTest
@testable import RockDock

class RockDockTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssert(true)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    // MARK: RockDock Tests
    // Tests to confirm that the Rock initializer returns when no name or a negative rating is provided.
    func testRockInitialization() {
        // Success case.
        let potentialItem = Rock(name: "Newest rock", photo: nil, rating: 5, owner: "Me")
        XCTAssertNotNil(potentialItem)
   
        // Failure cases.
        let noName = Rock(name: "", photo: nil, rating: 0, owner: "Me")
        XCTAssertNil(noName, "Empty name is invalid")
        
        let badRating = Rock(name: "Really bad rock", photo: nil, rating: -1, owner: "Me")
        XCTAssertNil(badRating)

    }
    
   }
