//
//  MobileDataUsageWireframe.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 8/1/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation
import UIKit

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
    
    func navigateToMobileDataYearUsageDetailPage(data: MobileYearlyDataUsageModel, from viewController: UIViewController) {
        var message: String = ""
        if data.isDecrease {
            message.append("Descrease quarter data in \(data.year):\n")
            let descreaseRecords = data.decreaseRecords.map({ (record) -> String in
                return "\(record.quarterYear!)-Q\(record.quarterNumber!)   \(record.volume)"
            })
            message.append(descreaseRecords.joined(separator: "\n"))
        } else {
            message.append("All quarter data in \(data.year):\n")
            let records = data.records.map({ (record) -> String in
                return "\(record.quarterYear!)-Q\(record.quarterNumber!)   \(record.volume)"
            })
            message.append(records.joined(separator: "\n"))
        }
        viewController.showAlert(title: "Mobile Data Usage", message: message, preferredStyle: .alert, completion: nil)
    }
}
