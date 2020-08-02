//
//  Reachability+Extensions.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 8/3/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation

extension Reachability: ReachabilityProtocol {
    public var isNetworkAvailable: Bool {
        let status = try? Reachability().connection
        
        if (status == Reachability.Connection.unavailable) {
            return false
        }
        
        return true
    }
}
