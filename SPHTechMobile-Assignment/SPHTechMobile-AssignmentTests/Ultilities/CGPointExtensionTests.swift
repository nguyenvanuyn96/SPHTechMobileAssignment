//
//  CGPointExtensionTests.swift
//  SPHTechMobile-AssignmentTests
//
//  Created by Uy Tikier on 8/3/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import XCTest
@testable import SPHTechMobile_Assignment

class CGPointExtensionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_AddingX() throws {
        var point = CGPoint(x: 16, y: 0)
        point = point.adding(x: 4)
        
        XCTAssertEqual(point.x, 20)
    }

    func test_AddingY() throws {
        var point = CGPoint(x: 16, y: 0)
        point = point.adding(y: 4)
        
        XCTAssertEqual(point.y, 4)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
