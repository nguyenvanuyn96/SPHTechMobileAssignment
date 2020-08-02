//
//  MobileDataUsageSectionItem.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 7/30/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation
import RxDataSources

enum MobileDataUsageSectionItem: IdentifiableType, Equatable {
    public typealias Identity = String
    
    case yearlyDataUsage(item: MobileYearlyDataUsageModel)
    case empty(description: String)
    
    public var identity: String {
        switch self {
        case .yearlyDataUsage(let item):
            let identify: String = "MobileDataUsageSectionItem_YearlyDataUsage_\(item.year)"
            return identify
        case .empty(let description):
            return "MobileDataUsageSectionItem_EmptyData_\(description.hashValue)"
        }
    }
    
    public static func == (lhs: MobileDataUsageSectionItem, rhs: MobileDataUsageSectionItem) -> Bool {
        guard lhs.identity == rhs.identity else { return false }
        
        switch (lhs, rhs) {
        case (.yearlyDataUsage(let lhsItem), .yearlyDataUsage(let rhsItem)):
            return lhsItem.totalAmount == rhsItem.totalAmount
                && lhsItem.records.count == rhsItem.records.count
                && lhsItem.year == rhsItem.year
        case (.empty(let lhsDescription), .empty(let rhsDescription)):
            return lhsDescription == rhsDescription
        default:
            return false
        }
    }
}
