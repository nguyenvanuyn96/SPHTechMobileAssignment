//
//  Link.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 7/30/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation

struct Link: Codable {
    let start: String?
    let next: String?

    enum CodingKeys: String, CodingKey {
        case start = "start"
        case next = "next"
    }
}
