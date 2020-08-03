//
//  MobileYearlyDataUsageModelTests.swift
//  SPHTechMobile-AssignmentTests
//
//  Created by Uy Tikier on 8/3/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import XCTest
@testable import SPHTechMobile_Assignment

class MobileYearlyDataUsageModelTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_AddRecord() throws {
        let model = MobileYearlyDataUsageModel(year: 1993)
        model.addRecord(Record(quarter: "1993-Q1", volume: "0.123456", id: 1))
        
        XCTAssertFalse(model.isDecrease)
        XCTAssertEqual(model.decreaseRecords.count, 0)
        XCTAssertEqual(model.totalAmount, 0.123456)
        XCTAssertEqual(model.records.count, 1)
        
        model.addRecord(Record(quarter: "1993-Q2", volume: "0.123457", id: 2))
        
        XCTAssertFalse(model.isDecrease)
        XCTAssertEqual(model.decreaseRecords.count, 0)
        XCTAssertEqual(model.totalAmount, 0.123456+0.123457)
        XCTAssertEqual(model.records.count, 2)
        
        let q4Record = Record(quarter: "1993-Q4", volume: "0.123455", id: 4)
        model.addRecord(q4Record)
        
        XCTAssertTrue(model.isDecrease)
        XCTAssertEqual(model.decreaseRecords.count, 1)
        XCTAssertEqual(model.decreaseRecords.first, q4Record)
        XCTAssertEqual(model.totalAmount, 0.123456+0.123457+0.123455)
        XCTAssertEqual(model.records.count, 3)
        
        let q3Record = Record(quarter: "1993-Q3", volume: "0.123452", id: 3)
        model.addRecord(q3Record)
        
        XCTAssertTrue(model.isDecrease)
        XCTAssertEqual(model.decreaseRecords.count, 1)
        XCTAssertEqual(model.decreaseRecords.first, q3Record)
        XCTAssertEqual(model.totalAmount, 0.123456+0.123457+0.123455+0.123452)
        XCTAssertEqual(model.records.count, 4)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
