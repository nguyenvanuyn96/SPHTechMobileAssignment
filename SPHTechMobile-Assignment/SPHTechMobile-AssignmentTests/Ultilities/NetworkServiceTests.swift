//
//  NetworkServiceTests.swift
//  SPHTechMobile-AssignmentTests
//
//  Created by Uy Tikier on 8/3/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import XCTest
import RxSwift
@testable import SPHTechMobile_Assignment

class NetworkServiceTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_SendRequestWithRequestData_Successful() throws {
        let config = NetworkConfig(baseUrl: "https://data.gov.sg.test")
        let logger = NetworkLoggerMock()

        let expectedResponseData = "Network response data".data(using: .utf8)!
        let session = NetworkSessionMock(response: nil,
                                         data: expectedResponseData)
        
        let networkService = DefaultNetworkService(session: session,
                                                   config: config,
                                                   logger: logger)
        let expectResponseData = expectation(description: "Got the network response data")
        
        var resultData: Data? = nil
        let disposeBadge = DisposeBag()
        networkService.request(endpoint: Endpoint(path: "api/action/datastore_search_test"))
            .subscribe(onNext: { (networkResult) in
                if case let .success(data) = networkResult {
                    resultData = data
                }
                expectResponseData.fulfill()
            }, onError: { (error) in
                expectResponseData.fulfill()
            }).disposed(by: disposeBadge)
        wait(for: [expectResponseData], timeout: 1)
        XCTAssertEqual(expectedResponseData, resultData)
    }

    func test_SendRequestWithRequestData_Failed() throws {
        let config = NetworkConfig(baseUrl: "https://data.gov.sg.test")
        let logger = NetworkLoggerMock()

        let error = NSError(domain: "https://data.gov.sg.test/api/action/datastore_search_test", code: 400, userInfo: nil)
        let session = NetworkSessionMock(response: nil,
                                         data: nil,
                                         error: error)
        
        let networkService = DefaultNetworkService(session: session,
                                                   config: config,
                                                   logger: logger)
        let expectResponseData = expectation(description: "Got the network response data")
        var resultData: Error? = nil
        let disposeBadge = DisposeBag()
        networkService.request(endpoint: Endpoint(path: "api/action/datastore_search_test"))
            .subscribe(onNext: { (networkResult) in
                if case let .failure(error) = networkResult {
                    resultData = error
                }
                expectResponseData.fulfill()
            }, onError: { (error) in
                resultData = error
                expectResponseData.fulfill()
            }).disposed(by: disposeBadge)
        wait(for: [expectResponseData], timeout: 1)
        XCTAssertNotNil(resultData)
    }

    func test_SendRequestWithRequestData_FailedHasHTTPResponseCode() throws {
        let config = NetworkConfig(baseUrl: "https://data.gov.sg.test")
        let logger = NetworkLoggerMock()

        let session = NetworkSessionMock(response: HTTPURLResponse(url: URL(string: "https://data.gov.sg.test/api/action/datastore_search_test")!,
                                                                   statusCode: 400,
                                                                   httpVersion: nil,
                                                                   headerFields: nil),
                                         data: nil,
                                         error: NSError(domain: "https://data.gov.sg.test/api/action/datastore_search_test", code: 400, userInfo: nil))
        
        let networkService = DefaultNetworkService(session: session,
                                                   config: config,
                                                   logger: logger)
        let expectResponseData = expectation(description: "Got the network response data")
        var resultData: Error? = nil
        let disposeBadge = DisposeBag()
        
        let expectedError = NetworkServiceError.errorStatusCode(statusCode: 400)
        networkService.request(endpoint: Endpoint(path: "api/action/datastore_search_test"))
            .subscribe(onNext: { (networkResult) in
                if case let .failure(error) = networkResult {
                    resultData = error
                }
                expectResponseData.fulfill()
            }, onError: { (error) in
                resultData = error
                expectResponseData.fulfill()
            }).disposed(by: disposeBadge)
        wait(for: [expectResponseData], timeout: 1)
        XCTAssertEqual(expectedError.localizedDescription, resultData?.localizedDescription)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

fileprivate class NetworkSessionMock: NetworkSessionProtocol {
    let response: HTTPURLResponse?
    let data: Data?
    let error: Error?
    
    init(response: HTTPURLResponse?, data: Data?, error: Error? = nil) {
        self.response = response
        self.data = data
        self.error = error
    }
    
    func loadData(from request: URLRequest) -> Observable<(Data?, URLResponse?, Error?)> {
        return Observable<(Data?, URLResponse?, Error?)>.just((data, response, error))
    }
}

fileprivate class NetworkLoggerMock: NetworkLoggerProtocol {
    public init() { }
    
    public func log(request: URLRequest) { }
    
    public func log(responseData data: Data?, response: URLResponse?) { }
    
    public func log(error: Error) { }
    
    public func log(statusCode: Int) { }
}
