//
//  Record.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 7/30/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation
import RealmSwift

class Record: Object, Codable {
    let volumeOfMobileData: String?
    let quarter: String?
    let id: Int?
    
    private(set) lazy var volume: Double = {
        guard let volume = self.volumeOfMobileData else { return 0 }
        
        return Double(volume) ?? 0
    }()
    
    private(set) lazy var quarterYear: Int? = {
        guard let quarterComponents = self.quarterComponents else { return nil }
        
        guard let quarterYearStr = quarterComponents.first else { return nil }
        
        return Int(quarterYearStr)
    }()
    
    private(set) lazy var quarterNumber: Int? = {
        guard let quarterComponents = self.quarterComponents else { return nil }
        
        guard var quarterNumberStr = quarterComponents.last else { return nil }
        
        quarterNumberStr.removeFirst(1)
        
        return Int(quarterNumberStr)
    }()
    
    private lazy var quarterComponents: [String]? = {
        return self.quarter?.components(separatedBy: "-")
    }()
    
    override static func ignoredProperties() -> [String] {
        return ["volume", "quarterYear", "quarterNumber", "quarterComponents"]
    }
    
    enum CodingKeys: String, CodingKey {
        case volumeOfMobileData = "volume_of_mobile_data"
        case quarter = "quarter"
        case id = "_id"
    }
}
