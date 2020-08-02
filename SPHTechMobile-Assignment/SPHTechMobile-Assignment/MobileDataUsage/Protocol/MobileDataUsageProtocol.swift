//
//  MobileDataUsageProtocol.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 7/30/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol MobileDataUsageViewProtocol: BaseViewProtocol, MobileDataUsageViewToPresenterProtocol {
    var presenter: (BasePresenterProtocol & MobileDataUsagePresenterToViewProtocol) { get }
}

protocol MobileDataUsageViewToPresenterProtocol where Self: UIViewController {
    var viewWillAppearObs: Observable<Void> { get }
    var viewDidAppearObs: Observable<Void> { get }
    var viewWillDisappearObs: Observable<Void> { get }
    var viewDidDisappearObs: Observable<Void> { get }
    var viewDidLoadObs: Observable<Void> { get }
    
    var pullToRefreshObs: Observable<Void> { get }
    var loadMoreObs: Observable<Void> { get }
    
    var tapViewYearDataItemObs: Observable<MobileYearlyDataUsageModel> { get }
    var tapViewChartObs: Observable<MobileYearlyDataUsageModel> { get }
}

protocol MobileDataUsagePresenterToViewProtocol {
    var dataSourceDrv: Driver<[MobileDataUsageSection]> { get }
    
    var showLoadingDrv: Driver<Bool> { get }
    var endInfiniteScrollDrv: Driver<Bool> { get }
    var showErrorDrv: Driver<Error> { get }
}

protocol MobileDataUsagePresenterProtocol: BasePresenterProtocol, MobileDataUsagePresenterToViewProtocol {
    var view: MobileDataUsageViewToPresenterProtocol? { get set }
    var interactor: MobileDataUsageInteractorProtocol? { get set }
    var wireframe: MobileDataUsageWireframeProtocol? { get set }
}

protocol MobileDataUsageInteractorProtocol: BaseInteractorProtocol {
    var endOfDataDrv: Driver<Bool> { get }
    
    func loadData() -> Observable<[Record]?>
    func loadMoreData() -> Observable<[Record]?>
}

protocol MobileDataUsageWireframeProtocol: BaseWireframeProtocol {
    static func createMobileDataUsageViewController() -> MobileDataUsageViewProtocol
    
    func navigateToMobileDataYearUsageDetailPage(data: MobileYearlyDataUsageModel, from viewController: UIViewController)
}

