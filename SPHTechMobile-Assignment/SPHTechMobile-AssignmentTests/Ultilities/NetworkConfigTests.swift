//
//  NetworkConfigTests.swift
//  SPHTechMobile-AssignmentTests
//
//  Created by Uy Tikier on 8/3/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import XCTest
@testable import SPHTechMobile_Assignment

class NetworkConfigTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_InitNetworkConfig() throws {
        let baseUrl: String = "https://data.gov.sg"
        let headers: [String:String] = ["x-access-token":"kjhakdjhfkjahsjkdhfkjahlskdjfhkjasdf"]
        let queryParameters: [String:String] = ["platform":"iOS",
                                                "app_version":"4.50.0"]
        let config = NetworkConfig(baseUrl: baseUrl,
                                   headers: headers,
                                   queryParameters: queryParameters)
        
        XCTAssertEqual(config.baseUrl, baseUrl)
        XCTAssertEqual(config.headers, headers)
        XCTAssertEqual(config.queryParameters, queryParameters)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
