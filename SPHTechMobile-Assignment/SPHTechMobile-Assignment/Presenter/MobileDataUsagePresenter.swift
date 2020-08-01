//
//  MobileDataUsagePresenter.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 7/31/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MobileDataUsagePresenter: MobileDataUsagePresenterProtocol {
    private let _emptyContentDescription: String = "Empty data"
    
    lazy var dataSourceDrv: Driver<[MobileDataUsageSection]> = {
        return self._mobileDataUsageSub.map({ [weak self] (records) -> [MobileDataUsageSection] in
            guard let self = self else { return [] }
            
            // If the newRecords is empty or nil, just return the currentDataSource
            guard var newRecords = records, !newRecords.isEmpty else { return self._currentDataSource }
            
            // Find the existed yearlySection, if NOT then just create an yearlySection and append the sectionItems data into
            guard var yearlySection = self._currentDataSource.first(where: { (section) -> Bool in
                return section.index == MobileDataUsageSectionIndex.yearlyDataUsage.rawValue
            }) else {
                let newYearlyDataModels = self.transformingRecords(newRecords)

                let newYearlySectionItems = newYearlyDataModels.map({ (item) -> MobileDataUsageSectionItem in
                    return MobileDataUsageSectionItem.yearlyDataUsage(item: item)
                })
                
                self._currentDataSource.append(MobileDataUsageSection(items: newYearlySectionItems, index: MobileDataUsageSectionIndex.yearlyDataUsage.rawValue))
                
                return self._currentDataSource
            }
            
            var yearlySectionItems = yearlySection.items
            
            // If found the existed yearlySection, then check the last sectionItem which is have enough 4 records as 4 quarters in a year yet?
            // If have not enough, just take the all records on it then put them into the newRecords. And at the sametime, remove the last yearlySectionItems due to it will re-append later
            if let lastYearlySectionItem = yearlySectionItems.last,
                case var MobileDataUsageSectionItem.yearlyDataUsage(item: item) = lastYearlySectionItem,
                item.records.count < 4 {
                newRecords.append(contentsOf: item.records)
                yearlySectionItems.removeLast()
            }
            
            // Transform the records data to the model and then create SectionItems to append into the yearlySectionItems
            let newYearlyDataModels = self.transformingRecords(newRecords)
            let newYearlySectionItems = newYearlyDataModels.map({ (item) -> MobileDataUsageSectionItem in
                return MobileDataUsageSectionItem.yearlyDataUsage(item: item)
            })
            yearlySectionItems.append(contentsOf: newYearlySectionItems)
            
            return self._currentDataSource
        })
        .asDriver(onErrorJustReturn: [])
        .throttle(RxTimeInterval.milliseconds(300))
    }()
    
    lazy var showLoadingDrv: Driver<Bool> = {
        return self._showLoadingSub.asDriver(onErrorJustReturn: false)
    }()
    
    lazy var showErrorDrv: Driver<Error> = {
        return self._showErrorSub.asDriver(onErrorJustReturn: NSError())
    }()
    
    lazy var endInfiniteScrollDrv: Driver<Bool> = {
        let suggestionDataSub = self._mobileDataUsageSub.map({ (data) -> Bool in
            guard let strongData = data else { return false }
            
            return strongData.isEmpty
        })
        
        guard let interactor = self.interactor else {
            return suggestionDataSub.asDriver(onErrorJustReturn: false)
        }
        
        return Observable.merge(suggestionDataSub,
                                interactor.endOfDataDrv.asObservable())
            .asDriver(onErrorJustReturn: false)
    }()
    
    weak var view: MobileDataUsageViewToPresenterProtocol? {
        didSet {
            self.setupObserveView()
        }
    }
    var interactor: MobileDataUsageInteractorProtocol?
    var wireframe: MobileDataUsageWireframeProtocol?
    
    private let _mobileDataUsageSub: PublishSubject<[Record]?> = PublishSubject<[Record]?>()
    private let _showLoadingSub: PublishSubject<Bool> = PublishSubject<Bool>()
    private let _showErrorSub: PublishSubject<Error> = PublishSubject<Error>()
    private var _currentDataSource: [MobileDataUsageSection] = []
    
    private let _disposeBag: DisposeBag = DisposeBag()
    
    private func setupObserveView() {
        guard let view = self.view else { return }
        
        view.tapViewYearDataItemObs
            .throttle(RxTimeInterval.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (model) in
                guard let self = self, let wireframe = self.wireframe else { return }
                
                wireframe.navigateToMobileDataYearUsageDetailPage(data: model)
            }).disposed(by: self._disposeBag)
        
        Observable.merge(view.viewDidLoadObs, view.pullToRefreshObs)
            .throttle(RxTimeInterval.milliseconds(1000), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                self._currentDataSource.removeAll()
                self._mobileDataUsageSub.onNext([])
                
                guard let strongInteractor = self.interactor else { return }
                
                strongInteractor.loadData()
                    .subscribe(onNext: { [weak self] (records) in
                        guard let self = self else { return }
                        
                        guard let newRecords = records, !newRecords.isEmpty else {
                            self._mobileDataUsageSub.onNext([])
                            return
                        }
                        
                        self._mobileDataUsageSub.onNext(newRecords)
                    }, onError: { [weak self] (error) in
                        guard let self = self else { return }
                        
                        self._mobileDataUsageSub.onNext([])
                        self._showErrorSub.onNext(error)
                    }, onCompleted: {
                        //todo
                    }).disposed(by: self._disposeBag)
            }).disposed(by: self._disposeBag)
        
        view.loadMoreObs
            .throttle(RxTimeInterval.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self, let strongInteractor = self.interactor else { return }
                
                strongInteractor.loadMoreData()
                    .subscribe(onNext: { [weak self] (records) in
                        guard let self = self else { return }
  
                        guard let newRecords = records else {
                            self._mobileDataUsageSub.onNext([])
                            return
                        }

                        self._mobileDataUsageSub.onNext(newRecords)
                    }, onError: { [weak self] (error) in
                        guard let self = self else { return }
                    
                        self._showErrorSub.onNext(error)
                    }, onCompleted: {
                        //todo
                    }).disposed(by: self._disposeBag)
            }).disposed(by: self._disposeBag)
    }
    
    private func transformingRecords(_ records: [Record]) -> [MobileYearlyDataUsageModel] {
        guard !records.isEmpty else { return [] }
        
        var yearlyDataDict: [Int: MobileYearlyDataUsageModel] = [:]
        
        for recordItem in records {
            guard let quarterYear = recordItem.quarterYear else { continue }
            
            if let existedYearlyDataModel = yearlyDataDict[quarterYear] {
                existedYearlyDataModel.addRecord(recordItem)
            } else {
                let newYearlyDataModel = MobileYearlyDataUsageModel(year: quarterYear)
                newYearlyDataModel.addRecord(recordItem)
                yearlyDataDict[quarterYear] = newYearlyDataModel
            }
        }
        
        let yearlyDataModels = yearlyDataDict.map { (key,model) -> MobileYearlyDataUsageModel in
            return model
        }.sorted { (item1, item2) -> Bool in
            return item1.year < item2.year
        }
        
        return yearlyDataModels
    }
}

