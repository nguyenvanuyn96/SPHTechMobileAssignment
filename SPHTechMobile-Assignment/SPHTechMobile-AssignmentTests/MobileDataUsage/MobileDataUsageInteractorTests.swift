//
//  MobileDataUsageInteractorTests.swift
//  SPHTechMobile-AssignmentTests
//
//  Created by Uy Tikier on 8/2/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import XCTest
import RxSwift
@testable import SPHTechMobile_Assignment

class MobileDataUsageInteractorTests: XCTestCase {
    

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_Load10DataSuccess_WhenHasNetworkConnection() throws {
        let apiService = MobileDataUsageApiServiceMock()
        let databaseService = MobileDataUsageDatabaseServiceMock()
        let reachability = ReachabilityMock(isNetworkAvailable: true)
        let interactor = MobileDataUsageInteractor(apiService: apiService, databaseService: databaseService, reachability: reachability)
        
        let disposeBadge = DisposeBag()
        
        let expectRecievedApiData = expectation(description: "recieved data response from API")
        let expectNotEndOfData = expectation(description: "not reached end of data")
        interactor.endOfDataDrv.asObservable().subscribe(onNext: { (isEndOfData) in
            if isEndOfData == false {
                expectNotEndOfData.fulfill()
            }
        }).disposed(by: disposeBadge)
        
        interactor.loadData().subscribe(onNext: { (response) in
            expectRecievedApiData.fulfill()
        }).disposed(by: disposeBadge)
        
        wait(for: [expectRecievedApiData, expectNotEndOfData], timeout: 1)
        let cachedCount = databaseService.getMobileDataUsage().count
        XCTAssertEqual(cachedCount, 10)
    }

    func test_LoadMore10DataSuccess_WhenHasNetworkConnection() throws {
        let apiService = MobileDataUsageApiServiceMock()
        let databaseService = MobileDataUsageDatabaseServiceMock()
        let reachability = ReachabilityMock(isNetworkAvailable: true)
        let interactor = MobileDataUsageInteractor(apiService: apiService, databaseService: databaseService, reachability: reachability)
        
        let disposeBadge = DisposeBag()
        
        let expectRecievedApiData = expectation(description: "recieved data response from API")
        let expectNotEndOfData = expectation(description: "not reached end of data")
        
        interactor.loadData().subscribe().disposed(by: disposeBadge)
        interactor.endOfDataDrv.asObservable().subscribe(onNext: { (isEndOfData) in
            if isEndOfData == false {
                expectNotEndOfData.fulfill()
            }
        }).disposed(by: disposeBadge)
        interactor.loadMoreData().subscribe(onNext: { (response) in
            expectRecievedApiData.fulfill()
        }).disposed(by: disposeBadge)
        
        wait(for: [expectRecievedApiData, expectNotEndOfData], timeout: 1)
        let cachedCount = databaseService.getMobileDataUsage().count
        XCTAssertGreaterThanOrEqual(cachedCount, 10)
    }

    func test_LoadMore10DataSuccess_ButHasReachedEndOfData_WhenHasNetworkConnection() throws {
        let apiService = MobileDataUsageApiServiceMock()
        let databaseService = MobileDataUsageDatabaseServiceMock()
        let reachability = ReachabilityMock(isNetworkAvailable: true)
        let interactor = MobileDataUsageInteractor(apiService: apiService, databaseService: databaseService, reachability: reachability)
        
        let disposeBadge = DisposeBag()
        
        let expectRecievedApiData = expectation(description: "recieved data response from API")
        let expectEndOfData = expectation(description: "reached end of data")
        interactor.endOfDataDrv.asObservable().subscribe(onNext: { (isEndOfData) in
            if isEndOfData == true {
                expectEndOfData.fulfill()
            }
        }).disposed(by: disposeBadge)
        interactor.loadData().subscribe().disposed(by: disposeBadge)
        apiService.isTestEmptyResponse = true
        interactor.loadMoreData().subscribe(onNext: { (response) in
            expectRecievedApiData.fulfill()
        }).disposed(by: disposeBadge)
        
        
        wait(for: [expectRecievedApiData, expectEndOfData], timeout: 1)
        let cachedCount = databaseService.getMobileDataUsage().count
        XCTAssertGreaterThanOrEqual(cachedCount, 10)
    }
    
    ///Please disconnect network before run this test case
    func test_LoadDataSuccess_WhenNoNetworkConnection() throws {
        let apiService = MobileDataUsageApiServiceMock()
        let databaseService = MobileDataUsageDatabaseServiceMock()
        let reachability = ReachabilityMock(isNetworkAvailable: false)
        let interactor = MobileDataUsageInteractor(apiService: apiService, databaseService: databaseService, reachability: reachability)
        
        let disposeBadge = DisposeBag()
        
        let cachedCount = databaseService.getMobileDataUsage().count
        let expectRecievedDatabaseData = expectation(description: "recieved data response from Database")
        let expectEndOfData = expectation(description: "reached end of data")
        interactor.endOfDataDrv.asObservable().subscribe(onNext: { (isEndOfData) in
            if isEndOfData == true {
                expectEndOfData.fulfill()
            }
        }).disposed(by: disposeBadge)
        
        var responseDataCount: Int = 0
        interactor.loadData().subscribe(onNext: { (response) in
            responseDataCount = response?.count ?? 0
            expectRecievedDatabaseData.fulfill()
        }).disposed(by: disposeBadge)
        
        wait(for: [expectRecievedDatabaseData, expectEndOfData], timeout: 1)
        XCTAssertEqual(cachedCount, responseDataCount)
    }

    func test_LoadMore10DataSuccess_WhenNoNetworkConnection() throws {
        let apiService = MobileDataUsageApiServiceMock()
        let databaseService = MobileDataUsageDatabaseServiceMock()
        let reachability = ReachabilityMock(isNetworkAvailable: true)
        let interactor = MobileDataUsageInteractor(apiService: apiService, databaseService: databaseService, reachability: reachability)
        
        let disposeBadge = DisposeBag()
        
        let expectRecievedDatabaseData = expectation(description: "recieved data response from Database")
        let expectEndOfData = expectation(description: "reached end of data when get from database")
        
        interactor.loadData().subscribe().disposed(by: disposeBadge)
        
        interactor.endOfDataDrv.asObservable().subscribe(onNext: { (isEndOfData) in
            if isEndOfData == true {
                expectEndOfData.fulfill()
            }
        }).disposed(by: disposeBadge)
        reachability.isNetworkAvailable = false
        interactor.loadMoreData().subscribe(onNext: { (response) in
            expectRecievedDatabaseData.fulfill()
        }).disposed(by: disposeBadge)
        
        let cachedCount = databaseService.getMobileDataUsage().count
        wait(for: [expectRecievedDatabaseData, expectEndOfData], timeout: 1)
        XCTAssertEqual(cachedCount, 10)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

fileprivate class ReachabilityMock: ReachabilityProtocol {
    var isNetworkAvailable: Bool = false
    
    init(isNetworkAvailable: Bool = false) {
        self.isNetworkAvailable = isNetworkAvailable
    }
}

fileprivate class MobileDataUsageDatabaseServiceMock: MobileDataUsageDatabaseServiceProtocol {
    private lazy var _cachedRecords: [Int:Record] = [:]
    
    func getMobileDataUsage() -> [Record] {
        return self._cachedRecords.values.map { (record) -> Record in
            return record
        }
    }
    
    func saveMobileDataUsage(records: [Record]) {
        for item in records {
            self._cachedRecords.updateValue(item, forKey: item.id)
        }
    }
    
    private func getMockData() -> [Int:Record] {
        let record1: Record = Record(quarter: "2005-Q4", volume: "0.000801", id: 6)
        let record2: Record = Record(quarter: "2006-Q1", volume: "0.00089", id: 7)
        let record3: Record = Record(quarter: "2006-Q2", volume: "0.001189", id: 8)
        let record4: Record = Record(quarter: "2006-Q3", volume: "0.001735", id: 9)
        let record5: Record = Record(quarter: "2006-Q4", volume: "0.003323", id: 10)
        return [record1.id: record1,
                record2.id: record2,
                record3.id: record3,
                record4.id: record4,
                record5.id: record5]
    }
}

fileprivate class MobileDataUsageApiServiceMock: MobileDataUsageApiProtocol {
    private lazy var _mobileDataUsageResponse: MobileDataUsageResponse = {
        let jsonString = """
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
    """
        let jsonData = jsonString.data(using: .utf8)!
        let data = try! JSONDecoder().decode(MobileDataUsageResponse.self, from: jsonData)
        return data
    }()
    
    private lazy var _emptyMobileDataUsageResponse: MobileDataUsageResponse = {
        let jsonString = """
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
                        "records": [],
                        "_links": {
                            "start": "/api/action/datastore_search?resource_id=a807b7ab-6cad-4aa6-87d0-e283a7353a0f&limit=10",
                            "next": "/api/action/datastore_search?resource_id=a807b7ab-6cad-4aa6-87d0-e283a7353a0f&limit=10&offset=10"
                        },
                        "offset": 0,
                        "limit": 10,
                        "total": 59
                    }
                }
    """
        let jsonData = jsonString.data(using: .utf8)!
        let data = try! JSONDecoder().decode(MobileDataUsageResponse.self, from: jsonData)
        return data
    }()
    var isTestEmptyResponse: Bool = false
    func getMobileDataUsage(page: Int, limit: Int) -> Observable<MobileDataUsageResponse?> {
        if self.isTestEmptyResponse {
            return Observable.just(self._emptyMobileDataUsageResponse)
        } else {
            return Observable.just(self._mobileDataUsageResponse)
        }
    }
}

extension Record {
    convenience init(quarter: String, volume: String, id: Int) {
        self.init()
        
        self.quarter = quarter
        self.volumeOfMobileData = volume
        self.id = id
    }
}
