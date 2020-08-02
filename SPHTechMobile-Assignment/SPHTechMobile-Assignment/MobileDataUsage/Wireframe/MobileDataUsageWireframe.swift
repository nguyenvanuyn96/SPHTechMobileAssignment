//
//  MobileDataUsageWireframe.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 8/1/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation

class MobileDataUsageWireframe: MobileDataUsageWireframeProtocol {
    class func createMobileDataUsageViewController() -> MobileDataUsageViewProtocol {
        let presenter = MobileDataUsagePresenter()
        
        let apiService: MobileDataUsageApiProtocol = ApiService()
        let databaseService: MobileDataUsageDatabaseServiceProtocol = DatabaseService()
        
        let view = MobileDataUsageViewController(presenter: presenter)
        let interactor = MobileDataUsageInteractor(apiService: apiService, databaseService: databaseService)
        let wireframe = MobileDataUsageWireframe()
        
        presenter.view = view
        presenter.interactor = interactor
        presenter.wireframe = wireframe
        
        return view
    }
    
    func navigateToMobileDataYearUsageDetailPage(data: MobileYearlyDataUsageModel) {
        //todo
    }
}
