//
//  MobileDataUsageSection.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 7/30/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation
import RxDataSources

enum MobileDataUsageSectionIndex: Int {
    case yearlyDataUsage
    case emptyData
}

class MobileDataUsageSection: AnimatableSectionModelType, IdentifiableType {
    typealias Identity = String
    typealias Item = MobileDataUsageSectionItem
    
    var index: Int
    var title: String?
    var items: [Item]
    
    var identity: String {
        let titleHash: Int = (title ?? "").hashValue
        let firstItemIdentity: String = items.first?.identity ?? ""
        let identity: String = "MobileDataUsageSection_\(titleHash)_\(firstItemIdentity)_\(index)"
        
        return identity
    }
    
    init(items: [Item],
         index: Int,
         title: String? = nil) {
        self.items = items
        self.index = index
        self.title = title
    }
    
    required init(original: MobileDataUsageSection, items: [Item]) {
        self.title = original.title
        self.index = original.index
        self.items = items
    }
}
