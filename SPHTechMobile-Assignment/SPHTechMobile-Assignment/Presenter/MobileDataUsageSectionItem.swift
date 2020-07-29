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
            let identify: String = "MobileDataUsageSectionItem_YearlyDataUsage_\(item.year ?? "2020")_\(item.totalAmount ?? 0)_\(item.records?.count ?? 0)_\(item.isDecrease ?? false)"
            return identify
        case .empty(let description):
            return "MobileDataUsageSectionItem_YearlyDataUsage_\(description.hashValue)"
        }
    }
    
    public static func == (lhs: MobileDataUsageSectionItem, rhs: MobileDataUsageSectionItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}
