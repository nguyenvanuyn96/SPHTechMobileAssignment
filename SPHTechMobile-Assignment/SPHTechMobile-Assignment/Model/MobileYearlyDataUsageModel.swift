//
//  MobileYearlyDataUsageModel.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 7/30/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation

class MobileYearlyDataUsageModel {
    let year: Int
    private(set) var totalAmount: Double = 0
    private(set) var records: [Record] = []
    private(set) var isDecrease: Bool = false
    var decreaseRecords: [Record] {
        guard self.isDecrease else { return [] }
        
        var result: [Record] = []
        var previousRecordVolume: Double = 0
        for recordItem in self.records {
            if previousRecordVolume > recordItem.volume {
                result.append(recordItem)
            }
            previousRecordVolume = recordItem.volume
        }
        
        return result
    }
    
    init(year: Int) {
        self.year = year
    }
    
    func addRecord(_ newRecord: Record) {
        guard let newRecordQuarterNumber = newRecord.quarterNumber else { return }
        
        let newRecordVolume: Double = newRecord.volume
        self.totalAmount += newRecordVolume
        
        guard !self.records.isEmpty else {
            self.records.append(newRecord)
            return
        }

        for i in 0..<self.records.count {
            let recordItem = self.records[i]
            guard let quarterNumber = recordItem.quarterNumber else { continue }
            
            if newRecordQuarterNumber <= quarterNumber {
                self.records.insert(newRecord, at: i)
                if newRecordVolume > recordItem.volume {
                    self.isDecrease = true
                }
                break
            } else if let nextRecordItem = self.records[exist: i+1] {
                if let nextQuarterNumber = nextRecordItem.quarterNumber,
                    newRecordQuarterNumber <= nextQuarterNumber {
                    self.records.insert(newRecord, at: i+1)
                    if newRecordVolume < recordItem.volume || newRecordVolume > nextRecordItem.volume {
                        self.isDecrease = true
                    }
                    break
                }
            } else {
                self.records.append(newRecord)
                if newRecordVolume < recordItem.volume {
                    self.isDecrease = true
                }
            }
        }
    }
}
