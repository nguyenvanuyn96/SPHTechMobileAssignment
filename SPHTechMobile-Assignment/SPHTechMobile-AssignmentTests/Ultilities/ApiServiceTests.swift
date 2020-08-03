//
//  ApiServiceTests.swift
//  SPHTechMobile-AssignmentTests
//
//  Created by Uy Tikier on 8/3/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import XCTest
import RxSwift
@testable import SPHTechMobile_Assignment

class ApiServiceTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_GetMobileDataUsageSuccessful() throws {
        let apiService = ApiService(networkService: NetworkServiceMockForResponseSuccessMobileDataUsage())
        let expectRecievedResponse = expectation(description: "recieved api response")
        let disposeBadge = DisposeBag()
        apiService.getMobileDataUsage(page: 0, limit: 10)
            .subscribe(onNext: { (response) in
                if response != nil {
                    expectRecievedResponse.fulfill()
                }
            }).disposed(by: disposeBadge)
        
        wait(for: [expectRecievedResponse], timeout: 1)
    }
    
    func test_GetMobileDataUsageSuccessful_ButWrongDataResponse() throws {
        let apiService = ApiService(networkService:
            NetworkServiceMockForResponseSuccessMobileDataUsage(jsonResponse: """
                                                                        "volume_of_mobile_data": "0.003323",
                                                                        "quarter": "2006-Q4",
                                                                        "_id": 10
                                                                """))
        let expectRecievedResponse = expectation(description: "recieved api error response")
        let disposeBadge = DisposeBag()
        apiService.getMobileDataUsage(page: 0, limit: 10)
            .subscribe(onNext: { (response) in
                if response == nil {
                    expectRecievedResponse.fulfill()
                }
            }, onError: { (error) in
                expectRecievedResponse.fulfill()
            }).disposed(by: disposeBadge)
        
        wait(for: [expectRecievedResponse], timeout: 1)
    }

    func test_GetMobileDataUsageFailed() throws {
        let apiService = ApiService(networkService: NetworkServiceMockForResponseFailedMobileDataUsage())
        let expectRecievedResponse = expectation(description: "recieved api error response")
        let disposeBadge = DisposeBag()
        apiService.getMobileDataUsage(page: 0, limit: 10)
            .subscribe(onNext: { (response) in
                if response == nil {
                    expectRecievedResponse.fulfill()
                }
            }, onError: { (error) in
                expectRecievedResponse.fulfill()
            }).disposed(by: disposeBadge)
        
        wait(for: [expectRecievedResponse], timeout: 1)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

fileprivate class NetworkServiceMockForResponseSuccessMobileDataUsage: NetworkServiceProtocol {
    private let _jsonResponse: String
    init(jsonResponse: String = """
                {
                    "help": "https://data.gov.sg/api/3/action/help_show?name=datastore_search",
                    "success": true,
                    "result": {
                        "resource_id": "a807b7ab-6cad-4aa6-87d0-e283a7353a0f",
                        "fields": [{
                            "type": "int4",
                            "id": "_id"
                        }, {
                            "type": "text",
                            "id": "quarter"
                        }, {
                            "type": "numeric",
                            "id": "volume_of_mobile_data"
                        }],
                        "records": [{
                            "volume_of_mobile_data": "0.000384",
                            "quarter": "2004-Q3",
                            "_id": 1
                        }, {
                            "volume_of_mobile_data": "0.000543",
                            "quarter": "2004-Q4",
                            "_id": 2
                        }, {
                            "volume_of_mobile_data": "0.00062",
                            "quarter": "2005-Q1",
                            "_id": 3
                        }, {
                            "volume_of_mobile_data": "0.000634",
                            "quarter": "2005-Q2",
                            "_id": 4
                        }, {
                            "volume_of_mobile_data": "0.000718",
                            "quarter": "2005-Q3",
                            "_id": 5
                        }, {
                            "volume_of_mobile_data": "0.000801",
                            "quarter": "2005-Q4",
                            "_id": 6
                        }, {
                            "volume_of_mobile_data": "0.00089",
                            "quarter": "2006-Q1",
                            "_id": 7
                        }, {
                            "volume_of_mobile_data": "0.001189",
                            "quarter": "2006-Q2",
                            "_id": 8
                        }, {
                            "volume_of_mobile_data": "0.001735",
                            "quarter": "2006-Q3",
                            "_id": 9
                        }, {
                            "volume_of_mobile_data": "0.003323",
                            "quarter": "2006-Q4",
                            "_id": 10
                        }],
                        "_links": {
                            "start": "/api/action/datastore_search?resource_id=a807b7ab-6cad-4aa6-87d0-e283a7353a0f&limit=10",
                            "next": "/api/action/datastore_search?resource_id=a807b7ab-6cad-4aa6-87d0-e283a7353a0f&limit=10&offset=10"
                        },
                        "offset": 0,
                        "limit": 10,
                        "total": 59
                    }
                }
    """) {
        self._jsonResponse = jsonResponse
    }
    func request(endpoint: RequestDataProtocol) -> Observable<Result<Data?, NetworkServiceError>> {
        let jsonData = self._jsonResponse.data(using: .utf8)!
        
        return Observable.just(.success(jsonData))
    }
}

fileprivate class NetworkServiceMockForResponseFailedMobileDataUsage: NetworkServiceProtocol {
    func request(endpoint: RequestDataProtocol) -> Observable<Result<Data?, NetworkServiceError>> {
        return Observable.just(.failure(NetworkServiceError.dataError(code: -100, message: "System error")))
    }
}
