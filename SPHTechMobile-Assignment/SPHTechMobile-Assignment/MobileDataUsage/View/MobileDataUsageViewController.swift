//
//  MobileDataUsageViewController.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 8/1/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation
import RxSwift
import SnapKit
import Reusable
import ESPullToRefresh
import RxDataSources

@objcMembers
class MobileDataUsageViewController: UIViewController, MobileDataUsageViewProtocol {
    lazy var viewWillAppearObs: Observable<Void> = {
        return self._viewWillAppearSub.asObservable()
    }()
    lazy var viewDidAppearObs: Observable<Void> = {
        return self._viewDidAppearSub.asObservable()
    }()
    lazy var viewWillDisappearObs: Observable<Void> = {
        return self._viewWillDisappearSub.asObservable()
    }()
    lazy var viewDidDisappearObs: Observable<Void> = {
        return self._viewDidDisappearSub.asObservable()
    }()
    lazy var viewDidLoadObs: Observable<Void> = {
        return self._viewDidLoadSub.asObservable()
    }()
    lazy var pullToRefreshObs: Observable<Void> = {
        return self._pullToRefreshSub.asObservable()
    }()
    lazy var loadMoreObs: Observable<Void> = {
        return self._loadMoreSub.asObservable()
    }()
    lazy var tapViewYearDataItemObs: Observable<MobileYearlyDataUsageModel> = {
        return self._tapViewYearDataItemSub.asObservable()
    }()
    lazy var tapViewChartObs: Observable<MobileYearlyDataUsageModel> = {
        return self._tapViewChartSub.asObservable()
    }()
    
    var presenter: (BasePresenterProtocol & MobileDataUsagePresenterToViewProtocol)

    private let _viewDidLoadSub = PublishSubject<Void>()
    private let _viewWillAppearSub = PublishSubject<Void>()
    private let _viewDidAppearSub = PublishSubject<Void>()
    private let _viewWillDisappearSub = PublishSubject<Void>()
    private let _viewDidDisappearSub = PublishSubject<Void>()
    private let _loadMoreSub = PublishSubject<Void>()
    private let _pullToRefreshSub = PublishSubject<Void>()
    
    private let _tapViewYearDataItemSub = PublishSubject<MobileYearlyDataUsageModel>()
    private let _tapViewChartSub = PublishSubject<MobileYearlyDataUsageModel>()
    
    private var _dataSource: RxTableViewSectionedAnimatedDataSource<MobileDataUsageSection>?

    private let _disposeBag: DisposeBag = DisposeBag()

    private lazy var _tableView: UITableView = {
        let view = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        view.backgroundColor = UIColor.systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        view.alwaysBounceVertical = true
        view.delegate = self
        view.showsVerticalScrollIndicator = true
        view.showsHorizontalScrollIndicator = false
        let animator: ESRefreshHeaderAnimator = ESRefreshHeaderAnimator(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        animator.executeIncremental = 70
        animator.trigger = 164
        view.es.addPullToRefresh(animator: animator, handler: { [unowned self] in
            view.es.resetNoMoreData()
            view.es.stopLoadingMore()
            self._pullToRefreshSub.onNext(())
        })
        view.es.addInfiniteScrolling { [unowned self] in
            self._loadMoreSub.onNext(())
        }
        view.es.resetNoMoreData()
        view.register(cellType: MobileDataUsageYearlyDataTableViewCell.self)
        view.register(cellType: MobileDataUsageEmptyTableViewCell.self)

        return view
    }()
    
    override var prefersStatusBarHidden: Bool {
        return false
    }

    init(presenter: (BasePresenterProtocol & MobileDataUsagePresenterToViewProtocol)) {
        self.presenter = presenter
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupViews()
        self.setupLayout()

        self.skinTableView()
        self.bindTableView()
        self.setupObservePresenter()

        self._viewDidLoadSub.onNext(())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self._viewDidAppearSub.onNext(())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self._viewWillAppearSub.onNext(())
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self._viewDidDisappearSub.onNext(())
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self._viewWillDisappearSub.onNext(())
    }
    
    private func skinTableView() {
        self._dataSource = RxTableViewSectionedAnimatedDataSource<MobileDataUsageSection>(configureCell: { (dataSource, tableView, indexPath, section) in
            let sectionItem: MobileDataUsageSectionItem = dataSource[indexPath]
            switch sectionItem {
            case .yearlyDataUsage(item: let data):
                let cell: MobileDataUsageYearlyDataTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.configCell(data: data)
                cell.onTapViewChartButton = {[weak self] (model) in
                    guard let self = self else { return }
                    
                    self._tapViewChartSub.onNext(model)
                }
                return cell
            case .empty(description: let description):
                let cell: MobileDataUsageEmptyTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                cell.configCell(emptyDescription: description)
                return cell
            }
        })
        self._dataSource?.animationConfiguration = AnimationConfiguration(insertAnimation: .top,
                                                                          reloadAnimation: .fade,
                                                                          deleteAnimation: .top)
    }
    
    private func setupObservePresenter() {
        guard let dataSource = self._dataSource else { return }
        
        self.presenter.dataSourceDrv
            .map({ [weak self] (data) -> [MobileDataUsageSection] in
                self?.endLoadData()
                return data
            })
            .drive(self._tableView.rx.items(dataSource: dataSource))
            .disposed(by: self._disposeBag)
        
        self.presenter.showErrorDrv
            .drive(onNext: { [weak self] (error) in
                self?.endLoadData()
                self?.showAlert(message: error.localizedDescription)
            })
            .disposed(by: self._disposeBag)
        
        self.presenter.endInfiniteScrollDrv
            .drive(onNext: { [weak self] (isEnded) in
                guard let self = self else { return }
                
                self.endLoadData()
                if isEnded {
                    self._tableView.es.noticeNoMoreData()
                } else {
                    self._tableView.es.addInfiniteScrolling { [unowned self] in
                        self._loadMoreSub.onNext(())
                    }
                }
            })
            .disposed(by: self._disposeBag)
    }
    
    private func endLoadData() {
        self._tableView.es.stopPullToRefresh()
        self._tableView.es.stopLoadingMore()
    }
    
    func bindTableView() {
        //do something
    }
}

extension MobileDataUsageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let sectionItem = self._dataSource?.sectionModels[indexPath.section].items[indexPath.row] else { return }
        
        guard case let MobileDataUsageSectionItem.yearlyDataUsage(item: model) = sectionItem else { return }
        
        self._tapViewYearDataItemSub.onNext(model)
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        guard let sectionItem = self._dataSource?.sectionModels[indexPath.section].items[indexPath.row] else { return UITableView.automaticDimension }
//
//        guard case let MobileDataUsageSectionItem.yearlyDataUsage(item: model) = sectionItem else { return UITableView.automaticDimension }
//
//        guard let cachedCellHeight = model.cellHeight else { return UITableView.automaticDimension }
//
//        return cachedCellHeight
//    }
//
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        guard let sectionItem = self._dataSource?.sectionModels[indexPath.section].items[indexPath.row] else { return }
//
//        guard case let MobileDataUsageSectionItem.yearlyDataUsage(item: model) = sectionItem else { return }
//
//        guard model.cellHeight == nil else { return }
//
//        model.cellHeight = cell.frame.size.height
//    }
//
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        guard let sectionItem = self._dataSource?.sectionModels[indexPath.section].items[indexPath.row] else { return UITableView.automaticDimension }
//
//        guard case let MobileDataUsageSectionItem.yearlyDataUsage(item: model) = sectionItem else { return UITableView.automaticDimension }
//
//        guard let cachedCellHeight = model.cellHeight else { return UITableView.automaticDimension }
//
//        return cachedCellHeight
//    }
}

//MARK: - Setup views & layout
extension MobileDataUsageViewController {
    fileprivate func setupViews() {
        self.title = "Mobile Data Usage"
        self.view.addSubview(self._tableView)
    }

    fileprivate func setupLayout() {
        self._tableView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(0)
        }
    }
}

