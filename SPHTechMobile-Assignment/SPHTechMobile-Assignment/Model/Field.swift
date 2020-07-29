//
//  Field.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 7/30/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation

enum FieldType: String, Codable {
    case text
    case numeric
    case int4
    
    enum CodingKeys: String, CodingKey
    {
        case text = "text"
        case numeric = "numeric"
        case int4 = "int4"
    }
}

struct Field: Codable {
    let type: FieldType?
    let id: String?
    
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case id = "id"
    }
}

