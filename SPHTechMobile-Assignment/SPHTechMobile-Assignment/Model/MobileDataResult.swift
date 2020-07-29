//
//  MobileDataResult.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 7/30/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation

struct MobileDataResult: Codable {
    let resourceId: String?
    let fields: [Field]?
    let records: [Record]?
    let links: Link?
    var limit: Int?
    let total: Int?
    var offset: Int?
    
    enum CodingKeys: String, CodingKey {
        case resourceId = "resource_id"
        case fields = "fields"
        case records = "records"
        case links = "_links"
        case limit = "limit"
        case total = "total"
    }
}
