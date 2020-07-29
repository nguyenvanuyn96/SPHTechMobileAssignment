//
//  Record.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 7/30/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation

struct Record: Codable {
    let volumeOfMobileData: String?
    let quarter: String?
    let id: Int?
    
    enum CodingKeys: String, CodingKey {
        case volumeOfMobileData = "volume_of_mobile_data"
        case quarter = "quarter"
        case id = "_id"
    }
}
