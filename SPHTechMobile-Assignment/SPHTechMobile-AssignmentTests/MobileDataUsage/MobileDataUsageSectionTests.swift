//
//  MobileDataUsageSectionTests.swift
//  SPHTechMobile-AssignmentTests
//
//  Created by Uy Tikier on 8/3/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import XCTest
@testable import SPHTechMobile_Assignment

class MobileDataUsageSectionTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_InitMobileDataUsageSection() throws {
        let section = MobileDataUsageSection(items: [], index: 1, title: "Test")
        XCTAssertEqual(section.items.count, 0)
        XCTAssertEqual(section.index, 1)
        XCTAssertEqual(section.title, "Test")
        
        let section1 = MobileDataUsageSection(original: section, items: [MobileDataUsageSectionItem.empty(description: "Test empty data")])
        XCTAssertEqual(section1.items.count, 1)
        XCTAssertEqual(section1.index, 1)
        XCTAssertEqual(section1.title, "Test")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
