//
//  MobileDataUsageDatabaseServiceTests.swift
//  SPHTechMobile-AssignmentTests
//
//  Created by Uy Tikier on 8/3/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import XCTest
import RxSwift
@testable import SPHTechMobile_Assignment

class MobileDataUsageDatabaseServiceTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let databaseService = DatabaseService()
        databaseService.deleteAll()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_GetCachedRecords_ButHasNoDataStoredBefore() throws {
        let databaseService = DatabaseService()
        
        let records = databaseService.getMobileDataUsage()
        
        XCTAssertEqual(records.count, 0)
    }
    
    func test_SaveRecordsSuccess() throws {
        let databaseService = DatabaseService()
        
        let recordsCountBeforeSaved = databaseService.getMobileDataUsage().count
        
        databaseService.saveMobileDataUsage(records: self.mock5RecordsData)
        
        let recordsCountAfterSaved = databaseService.getMobileDataUsage().count
        
        XCTAssertEqual(recordsCountBeforeSaved, 0)
        XCTAssertEqual(recordsCountAfterSaved, 5)
    }
    
    func test_SaveDuplicatedRecordsSuccess() throws {
        let databaseService = DatabaseService()
        
        let recordsCountBeforeSaved = databaseService.getMobileDataUsage().count
        
        databaseService.saveMobileDataUsage(records: self.mock5RecordsData)
        
        let recordsCountAfterSaved1 = databaseService.getMobileDataUsage().count
        
        var mockData = self.mock5RecordsData
        for i in 0..<mockData.count {
            let item = mockData[i]
            mockData[i] = Record(quarter: item.quarter!, volume: "\(Double.random(in: 0...1000))", id: item.id)
        }
        databaseService.saveMobileDataUsage(records: mockData)
        
        let recordsAfterSaved2 = databaseService.getMobileDataUsage()
        
        XCTAssertEqual(recordsCountBeforeSaved, 0)
        XCTAssertEqual(recordsCountAfterSaved1, 5)
        XCTAssertEqual(recordsAfterSaved2.count, 5)
        XCTAssertEqual(recordsAfterSaved2[0].volume, mockData[0].volume)
        XCTAssertEqual(recordsAfterSaved2[1].volume, mockData[1].volume)
        XCTAssertEqual(recordsAfterSaved2[2].volume, mockData[2].volume)
        XCTAssertEqual(recordsAfterSaved2[3].volume, mockData[3].volume)
        XCTAssertEqual(recordsAfterSaved2[4].volume, mockData[4].volume)
    }
    
    func test_SaveRecords_WhichHaveDuplicated_Success() throws {
        let databaseService = DatabaseService()
        
        let recordsCountBeforeSaved = databaseService.getMobileDataUsage().count
        
        databaseService.saveMobileDataUsage(records: self.mock5RecordsData)
        
        let recordsCountAfterSaved1 = databaseService.getMobileDataUsage().count
        
        var mockData = self.mock5RecordsData
        for i in 0..<5 {
            let item = mockData[i]
            mockData[i] = Record(quarter: item.quarter!, volume: "\(Double.random(in: 0...1000))", id: item.id)
        }
        for i in 0..<3 {
            mockData.append(Record(quarter: "1993-Q\(i)", volume: "\(Double.random(in: 0...1000))", id: i))
        }
        databaseService.saveMobileDataUsage(records: mockData)
        
        let recordsAfterSaved2 = databaseService.getMobileDataUsage()
        
        XCTAssertEqual(recordsCountBeforeSaved, 0)
        XCTAssertEqual(recordsCountAfterSaved1, 5)
        XCTAssertEqual(recordsAfterSaved2.count, 8)
        XCTAssertEqual(recordsAfterSaved2[0].volume, mockData[0].volume)
        XCTAssertEqual(recordsAfterSaved2[1].volume, mockData[1].volume)
        XCTAssertEqual(recordsAfterSaved2[5].volume, mockData[5].volume)
        XCTAssertEqual(recordsAfterSaved2[3].volume, mockData[3].volume)
        XCTAssertEqual(recordsAfterSaved2[6].volume, mockData[6].volume)
    }
    
    func test_GetObjects() throws {
        let databaseService = DatabaseService()
        
        let recordsCountBeforeSaved = databaseService.objects(Record.self).count
        
        databaseService.saveMobileDataUsage(records: self.mock5RecordsData)
        
        let recordsCountAfterSaved = databaseService.objects(Record.self).count
        let recordsCountWithFilterAfterSaved = databaseService.objects(Record.self, filter: NSPredicate(format: "quarter == %@", "2006-Q1")).count
        let notFoundRecordsWithFilterAfterSaved = databaseService.objects(Record.self, filter: NSPredicate(format: "quarter == %@", "2006-Q9")).count
        
        XCTAssertEqual(recordsCountBeforeSaved, 0)
        XCTAssertEqual(recordsCountAfterSaved, 5)
        XCTAssertEqual(recordsCountWithFilterAfterSaved, 1)
        XCTAssertEqual(notFoundRecordsWithFilterAfterSaved, 0)
    }
    
    func test_ObservableObjects() throws {
        let databaseService = DatabaseService()
        
        let disposeBadge = DisposeBag()
        let expectRecievedRecordDatabaseChanged = expectation(description: "recieved record database change")
        let expectRecievedRecordDatabaseChangedWithFilter = expectation(description: "recieved record database change has match with filter")
        let expectRecievedRecordDatabaseChangedWithSorted = expectation(description: "recieved record database change has match with filter")
        expectRecievedRecordDatabaseChanged.assertForOverFulfill = false
        expectRecievedRecordDatabaseChangedWithFilter.assertForOverFulfill = false
        expectRecievedRecordDatabaseChangedWithSorted.assertForOverFulfill = false
        var expectRecievedRecordDatabaseChangedFulfillmentCount: Int = 0
        var expectRecievedRecordDatabaseChangedWithFilterFulfillmentCount: Int = 0
        var expectRecievedRecordDatabaseChangedWithSortedFulfillmentCount: Int = 0
        var recordsCount: Int = 0
        var recordsCountWithFilter: Int = 0
        var recordsCountWithSorted: Int = 0
        databaseService.observableObjects(type: Record.self)
            .subscribe(onNext: { (records) in
                expectRecievedRecordDatabaseChanged.fulfill()
                expectRecievedRecordDatabaseChangedFulfillmentCount += 1
                recordsCount = records.count
            }).disposed(by: disposeBadge)
        databaseService.observableObjects(type: Record.self, filter: NSPredicate(format: "quarter contains %@", "2006"))
            .subscribe(onNext: { (records) in
                expectRecievedRecordDatabaseChangedWithFilter.fulfill()
                expectRecievedRecordDatabaseChangedWithFilterFulfillmentCount += 1
                recordsCountWithFilter = records.count
            }).disposed(by: disposeBadge)
        
        databaseService.observableObjects(type: Record.self, sortByKeyPath: "id", ascending: false)
            .subscribe(onNext: { (records) in
                expectRecievedRecordDatabaseChangedWithSorted.fulfill()
                expectRecievedRecordDatabaseChangedWithSortedFulfillmentCount += 1
                recordsCountWithSorted = records.count
            }).disposed(by: disposeBadge)
        
        databaseService.saveMobileDataUsage(records: self.mock5RecordsData)
        databaseService.saveMobileDataUsage(records: [Record(quarter: "2010-Q4", volume: "0.0987", id: 12),
                                                      Record(quarter: "2010-Q1", volume: "0.00089", id: 13)])
                                                      databaseService.saveMobileDataUsage(records: [Record(quarter: "2010-Q4", volume: "0.0987", id: 12),
                                                                                                    Record(quarter: "2010-Q1", volume: "0.00089", id: 13)])
        
        databaseService.saveMobileDataUsage(records: self.mock5RecordsData)
        wait(for: [expectRecievedRecordDatabaseChanged,
                   expectRecievedRecordDatabaseChangedWithFilter,
                   expectRecievedRecordDatabaseChangedWithSorted], timeout: 1)
        XCTAssertEqual(recordsCount, 7)
        XCTAssertEqual(recordsCountWithFilter, 4)
        XCTAssertEqual(recordsCountWithSorted, 7)
        XCTAssertEqual(expectRecievedRecordDatabaseChangedFulfillmentCount, 4)
        XCTAssertEqual(expectRecievedRecordDatabaseChangedWithFilterFulfillmentCount, 2)
        XCTAssertEqual(expectRecievedRecordDatabaseChangedWithSortedFulfillmentCount, 4)
    }
    
    func test_ReadObjects() throws {
        let databaseService = DatabaseService()
        
        let recordsCountBeforeSaved = databaseService.read(Record.self).count
        
        databaseService.saveMobileDataUsage(records: self.mock5RecordsData)
        
        let recordsCountAfterSaved = databaseService.objects(Record.self).count
        
        XCTAssertEqual(recordsCountBeforeSaved, 0)
        XCTAssertEqual(recordsCountAfterSaved, 5)
    }
    
    func test_CreateObjects() throws {
        let databaseService = DatabaseService()
        
        let recordsCountBeforeSaved = databaseService.read(Record.self).count
        
        databaseService.create(object: Record(quarter: "2016-Q4", volume: "0.098731", id: 996))
        databaseService.create(objects: [Record(quarter: "2016-Q5", volume: "0.098731", id: 997)])
        databaseService.createWithTransaction(objects: [Record(quarter: "2016-Q6", volume: "0.098731", id: 998)])
        databaseService.create(Record.self, value: Record(quarter: "2016-Q7", volume: "0.098731", id: 999))
        
        let recordsCountAfterSaved = databaseService.objects(Record.self).count
        
        XCTAssertEqual(recordsCountBeforeSaved, 0)
        XCTAssertEqual(recordsCountAfterSaved, 4)
    }
    
    func test_DeleteObject() throws {
        let databaseService = DatabaseService()
        
        let mockData = self.mock5RecordsData
        databaseService.saveMobileDataUsage(records: mockData)
        
        let recordsCountBeforeDeleted = databaseService.read(Record.self).count
        databaseService.delete(object: mockData[0])
        let recordsCountAfterDeleted = databaseService.read(Record.self).count
        XCTAssertEqual(recordsCountBeforeDeleted, 5)
        XCTAssertEqual(recordsCountAfterDeleted, 4)
    }
    
    func test_DeleteObjects() throws {
        let databaseService = DatabaseService()
        
        let mockData = self.mock5RecordsData
        databaseService.saveMobileDataUsage(records: mockData)
        
        let recordsResult = databaseService.objects(Record.self)
        databaseService.delete(objects: recordsResult)
        let recordsCountAfterDeleted2 = databaseService.read(Record.self).count
        
        XCTAssertEqual(recordsCountAfterDeleted2, 0)
    }
    
    
    func test_DeleteObjectsByKey() throws {
        let databaseService = DatabaseService()
        
        let mockData = self.mock5RecordsData
        databaseService.saveMobileDataUsage(records: mockData)
        
        databaseService.delete(type: Record.self, keys: [8,9,10])
        let recordsCountAfterDeleted3 = databaseService.read(Record.self).count
        XCTAssertEqual(recordsCountAfterDeleted3, 2)
    }
     
    func test_DeleteAllObjects() throws {
        let databaseService = DatabaseService()
        
        let mockData = self.mock5RecordsData
        databaseService.saveMobileDataUsage(records: mockData)
        databaseService.deleteAll()
        let recordsCountAfterDeletedAll = databaseService.read(Record.self).count
        XCTAssertEqual(recordsCountAfterDeletedAll, 0)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    private var mock5RecordsData: [Record] = {
        let record1: Record = Record(quarter: "2005-Q4", volume: "0.000801", id: 6)
        let record2: Record = Record(quarter: "2006-Q1", volume: "0.00089", id: 7)
        let record3: Record = Record(quarter: "2006-Q2", volume: "0.001189", id: 8)
        let record4: Record = Record(quarter: "2006-Q3", volume: "0.001735", id: 9)
        let record5: Record = Record(quarter: "2006-Q4", volume: "0.003323", id: 10)
        return [record1,
                record2,
                record3,
                record4,
                record5]
    }()

}
