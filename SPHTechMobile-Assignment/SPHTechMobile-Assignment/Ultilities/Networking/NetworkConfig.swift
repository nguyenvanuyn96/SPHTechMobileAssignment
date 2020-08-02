//
//  NetworkConfig.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 8/1/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation

public protocol NetworkConfigurable {
    var baseUrl: String { get }
    var headers: [String: String] { get }
    var queryParameters: [String: String] { get }
}

public struct NetworkConfig: NetworkConfigurable {
    public let baseUrl: String
    public let headers: [String: String]
    public let queryParameters: [String: String]
    
     public init(baseUrl: String,
                 headers: [String: String] = [:],
                 queryParameters: [String: String] = [:]) {
        self.baseUrl = baseUrl
        self.headers = headers
        self.queryParameters = queryParameters
    }
}
