//
//  EndpointTests.swift
//  SPHTechMobile-AssignmentTests
//
//  Created by Uy Tikier on 8/3/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import XCTest
@testable import SPHTechMobile_Assignment

class EndpointTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_InitEndpoint() throws {
        let path: String = "api/action/datastore_search"
        let queryParams: [String:Any] = ["limit":5]
        let headerParamaters: [String: String] = [:]
        let bodyParamaters: [String: Any] = [:]
        let endPoint = Endpoint(path: path,
                                method: .get,
                                queryParameters: queryParams,
                                headerParamaters: headerParamaters,
                                bodyParamaters: bodyParamaters,
                                bodyEncoding: .jsonSerializationData)
        
        XCTAssertEqual(endPoint.path, path)
        XCTAssertEqual(endPoint.method, .get)
        XCTAssertEqual(endPoint.queryParameters.count, queryParams.count)
        XCTAssertEqual(endPoint.headerParamaters, headerParamaters)
        XCTAssertEqual(endPoint.bodyParamaters.count, bodyParamaters.count)
        XCTAssertEqual(endPoint.bodyEncoding, .jsonSerializationData)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
