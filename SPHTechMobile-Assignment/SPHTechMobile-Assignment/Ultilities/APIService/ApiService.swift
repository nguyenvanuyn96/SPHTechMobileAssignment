//
//  ApiService.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 8/2/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation
import RxSwift

protocol MobileDataUsageApiProtocol {
    func getMobileDataUsage(page: Int, limit: Int) -> Observable<MobileDataUsageResponse?>
}

class ApiService {
    private let _networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = DefaultNetworkService(session: URLSession.shared, config: NetworkConfig(baseUrl: AppConfig.apiBaseUrl))) {
        self._networkService = networkService
    }
}
 
extension ApiService: MobileDataUsageApiProtocol {
    func getMobileDataUsage(page: Int, limit: Int) -> Observable<MobileDataUsageResponse?> {
        let params: [String: Any] = ["resource_id": "a807b7ab-6cad-4aa6-87d0-e283a7353a0f",
                                     "offset": page*limit,
                                     "limit": limit]
        
        let endpoint = Endpoint(path: "api/action/datastore_search",
                                queryParameters: params)
        
        return self._networkService.request(endpoint: endpoint).map({ (result) -> MobileDataUsageResponse in
            switch result {
            case .success(let responseData):
                guard let responseData = responseData else {
                    throw NetworkServiceError.serverError
                }
                
                guard let response = try? JSONDecoder().decode(MobileDataUsageResponse.self, from: responseData) else {
                    throw NetworkServiceError.serverError
                }
                
                return response
            case .failure(let error):
                throw error
            }
        })
    }
}
