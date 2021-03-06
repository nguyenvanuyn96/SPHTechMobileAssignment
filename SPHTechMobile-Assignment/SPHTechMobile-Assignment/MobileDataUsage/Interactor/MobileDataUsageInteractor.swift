//
//  MobileDataUsageInteractor.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 8/1/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MobileDataUsageInteractor: MobileDataUsageInteractorProtocol {
    private var _currentPage: Int = -1
    private let _limit: Int = 16
    private let _endOfDataSub: PublishSubject<Bool> = PublishSubject<Bool>()
    private let _apiService: MobileDataUsageApiProtocol
    private let _databaseService: MobileDataUsageDatabaseServiceProtocol
    private let _reachability: ReachabilityProtocol?
    
    init(apiService: MobileDataUsageApiProtocol, databaseService: MobileDataUsageDatabaseServiceProtocol, reachability: ReachabilityProtocol?) {
        self._apiService = apiService
        self._databaseService = databaseService
        self._reachability = reachability
    }
    
    lazy var endOfDataDrv: Driver<Bool> = {
        return self._endOfDataSub.asDriver(onErrorJustReturn: false)
    }()
    
    func loadData() -> Observable<[Record]?> {
        self._currentPage = -1
        return self.loadData(page: self._currentPage + 1, limit: self._limit)
    }
    
    func loadMoreData() -> Observable<[Record]?> {
        return self.loadData(page: self._currentPage + 1, limit: self._limit)
    }
    
    private func loadData(page: Int, limit: Int) -> Observable<[Record]?> {
        if !(self._reachability?.isNetworkAvailable ?? false) {
            return Observable<[Record]?>.create { [weak self] obs in
                guard let self = self else {
                    obs.onNext(nil)
                    obs.onCompleted()
                    return Disposables.create()
                }
                
                let records = self._databaseService.getMobileDataUsage()
                
                obs.onNext(records)
                obs.onCompleted()
                self._endOfDataSub.onNext(true)
                return Disposables.create()
            }
        } else {
            return self._apiService.getMobileDataUsage(page: page, limit: limit)
                .map({[weak self] (response) -> [Record]? in
                    guard let self = self else { return nil }
                    
                    guard let strongResponse = response else { return nil }
                    
                    self._currentPage += 1
                    if let responseRecords = strongResponse.result?.records,
                        responseRecords.count > 0 {
                        self._databaseService.saveMobileDataUsage(records: responseRecords)
                        self._endOfDataSub.onNext(false)
                    } else {
                        self._endOfDataSub.onNext(true)
                    }
                    
                    
                    return strongResponse.result?.records
                })
        }
    }
    
}

