//
//  MobileDataUsageResponse.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 7/30/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation

struct MobileDataUsageResponse: Codable {
    let help: String?
    let isSuccess: Bool?
    var result: MobileDataResult?
    
    enum CodingKeys: String, CodingKey {
        case help = "help"
        case isSuccess = "success"
        case result = "result"
    }
}

