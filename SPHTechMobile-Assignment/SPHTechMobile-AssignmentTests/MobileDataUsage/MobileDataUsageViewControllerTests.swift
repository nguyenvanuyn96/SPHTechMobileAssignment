//
//  MobileDataUsageViewControllerTests.swift
//  SPHTechMobile-AssignmentTests
//
//  Created by Uy Tikier on 8/3/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
@testable import SPHTechMobile_Assignment

class MobileDataUsageViewControllerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_TriggerViewDidLoadObs_WhenViewDidLoad() throws {
        let expectRecievedViewDidLoadObsEvent = expectation(description: "recieved event view did load")
        let expectRecievedViewWillAppearObsEvent = expectation(description: "recieved event view will appear")
        let expectRecievedViewDidAppearObsEvent = expectation(description: "recieved event view did appear")
        let expectRecievedViewWillDisappearObsEvent = expectation(description: "recieved event view will disappear")
        let expectRecievedViewDidDisappearObsEvent = expectation(description: "recieved event view did disappear")
        let disposeBag: DisposeBag = DisposeBag()
        
        let presenter = MobileDataUsagePresenterMock()
        let viewController = MobileDataUsageViewController(presenter: presenter)
        viewController.viewDidLoadObs
            .subscribe(onNext: { (arg0) in
                expectRecievedViewDidLoadObsEvent.fulfill()
            }).disposed(by: disposeBag)
        viewController.viewWillAppearObs
            .subscribe(onNext: { (arg0) in
                expectRecievedViewWillAppearObsEvent.fulfill()
            }).disposed(by: disposeBag)
        viewController.viewDidAppearObs
            .subscribe(onNext: { (arg0) in
                expectRecievedViewDidAppearObsEvent.fulfill()
            }).disposed(by: disposeBag)
        viewController.viewWillDisappearObs
            .subscribe(onNext: { (arg0) in
                expectRecievedViewWillDisappearObsEvent.fulfill()
            }).disposed(by: disposeBag)
        viewController.viewDidDisappearObs
            .subscribe(onNext: { (arg0) in
                expectRecievedViewDidDisappearObsEvent.fulfill()
            }).disposed(by: disposeBag)
        
        let window = UIWindow(frame:  UIScreen.main.bounds)
        window.makeKeyAndVisible()
        window.rootViewController = viewController
        
        wait(for: [expectRecievedViewDidLoadObsEvent,
                   expectRecievedViewWillAppearObsEvent,
                   expectRecievedViewDidAppearObsEvent],
             timeout: 1)
        
        window.rootViewController = nil
        wait(for: [expectRecievedViewWillDisappearObsEvent,
                   expectRecievedViewDidDisappearObsEvent],
             timeout: 1)
    }

    func test_TriggerViewWillAppearObs_WhenViewWillAppear() throws {
        let expectRecievedNeededEvent = expectation(description: "recieved event view will appear")
        let disposeBag: DisposeBag = DisposeBag()
        
        let presenter = MobileDataUsagePresenterMock()
        let viewController = MobileDataUsageViewController(presenter: presenter)
        viewController.viewWillAppearObs
            .subscribe(onNext: { (arg0) in
                expectRecievedNeededEvent.fulfill()
            }).disposed(by: disposeBag)
        
        let window = UIWindow(frame:  UIScreen.main.bounds)
        window.makeKeyAndVisible()
        window.rootViewController = viewController
        
        wait(for: [expectRecievedNeededEvent], timeout: 1)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

fileprivate class MobileDataUsagePresenterMock: BasePresenterProtocol & MobileDataUsagePresenterToViewProtocol {
    var dataSourceDrv: Driver<[MobileDataUsageSection]> = PublishSubject<[MobileDataUsageSection]>().asDriver(onErrorJustReturn: [])
    
    var showLoadingDrv: Driver<Bool> = PublishSubject<Bool>().asDriver(onErrorJustReturn: false)
    
    var showErrorDrv: Driver<Error> = PublishSubject<Error>().asDriver(onErrorJustReturn: NSError())
    
    var endInfiniteScrollDrv: Driver<Bool> = PublishSubject<Bool>().asDriver(onErrorJustReturn: false)
}
