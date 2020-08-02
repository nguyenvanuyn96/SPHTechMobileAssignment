//
//  RecordTests.swift
//  SPHTechMobile-AssignmentTests
//
//  Created by Uy Tikier on 8/2/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import XCTest
@testable import SPHTechMobile_Assignment

class RecordTests: XCTestCase {
    private lazy var _mockValidRecordJSONString: String = {
        let jsonString = """
                    {
                      "volume_of_mobile_data": "0.000801",
                      "quarter": "2005-Q4",
                      "_id": 6
                    }
        """
        return jsonString
    }()
    
    private lazy var _mockInValidRecordJSONString: String = {
        let jsonString = """
                    {
                      "volume_of_mobile_data": "true",
                      "quarter": "UyNguyenVan",
                      "_id": 6
                    }
        """
        return jsonString
    }()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_getVolume_WhenVolumeOfMobileData_EqualToNil_ThenReturn0() throws {
        let record = Record()
        
        XCTAssertEqual(record.volume, 0)
    }
    
    func test_getVolume_WhenVolumeOfMobileDataIsAnInvalidDoubleValueInString_ThenReturn0() throws {
        let jsonData = self._mockInValidRecordJSONString.data(using: .utf8)!
        let record = try! JSONDecoder().decode(Record.self, from: jsonData)
        
        XCTAssertEqual(record.volume, 0)
    }
    
    func test_getVolume_WhenVolumeOfMobileDataIsAValidDoubleValueInString_ThenReturnDoubleValue() throws {
        let jsonData = self._mockValidRecordJSONString.data(using: .utf8)!
        let record = try! JSONDecoder().decode(Record.self, from: jsonData)
        
        XCTAssertEqual(record.volume, 0.000801)
    }
    
    func test_getQuarterYear_WhenQuarterIsAnInvalidQuarterInString_ThenReturnNil() throws {
        let jsonData = self._mockInValidRecordJSONString.data(using: .utf8)!
        let record = try! JSONDecoder().decode(Record.self, from: jsonData)
        
        XCTAssertEqual(record.quarterYear, nil)
    }
    
    func test_getQuarterYear_WhenQuarterIsAValidQuarterInString_ThenReturnYearNumberValue() throws {
        
        let jsonData = self._mockValidRecordJSONString.data(using: .utf8)!
        let record = try! JSONDecoder().decode(Record.self, from: jsonData)
        
        XCTAssertEqual(record.quarterYear, 2005)
    }
    
    func test_getQuarterNumber_WhenQuarterIsAnInvalidQuarterInString_ThenReturnNil() throws {
        let jsonData = self._mockInValidRecordJSONString.data(using: .utf8)!
        let record = try! JSONDecoder().decode(Record.self, from: jsonData)
        
        XCTAssertEqual(record.quarterNumber, nil)
    }
    
    func test_getQuarterNumber_WhenQuarterIsAValidQuarterInString_ThenReturnQuarterNumberValue() throws {
        
        let jsonData = self._mockValidRecordJSONString.data(using: .utf8)!
        let record = try! JSONDecoder().decode(Record.self, from: jsonData)
        
        XCTAssertEqual(record.quarterNumber, 4)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
