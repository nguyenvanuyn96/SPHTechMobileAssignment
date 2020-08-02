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

    private var _isLoadingMore: Bool = true
    private let _disposeBag: DisposeBag = DisposeBag()
    private lazy var _loadMoreIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        view.startAnimating()
        view.color = UIColor.lightGray
        view.isHidden = false
        view.frame = CGRect(x: 0, y: 0, width: self._tableView.frame.width, height: 48)
        
        return view
    }()
    
    private lazy var _pullRefreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        view.attributedTitle = NSAttributedString(string: "Pull to refresh")
        view.backgroundColor = UIColor.white
        view.tintColor = UIColor.gray
        view.addTarget(self, action: #selector(didPullRefreshData), for: .valueChanged)
        
        return view
    }()

    private lazy var _tableView: UITableView = {
        let view = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        view.separatorStyle = UITableViewCell.SeparatorStyle.none
        view.alwaysBounceVertical = true
        view.delegate = self
        view.showsVerticalScrollIndicator = true
        view.showsHorizontalScrollIndicator = false
        view.estimatedRowHeight = 1
        view.register(cellType: MobileDataUsageYearlyDataTableViewCell.self)
        view.register(cellType: MobileDataUsageEmptyTableViewCell.self)

        return view
    }()
    
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
                                                                          deleteAnimation: .fade)
    }
    
    private func setupObservePresenter() {
        guard let dataSource = self._dataSource else { return }
        
        self.presenter.dataSourceDrv
            .map({ [weak self] (data) -> [MobileDataUsageSection] in
                if data.contains(where: { (section) -> Bool in
                    return section.index == MobileDataUsageSectionIndex.emptyData.rawValue
                }) {
                    self?.setLoadMoreIndicator(isShow: false)
                }
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
                    self.setLoadMoreIndicator(isShow: false)
                }
            })
            .disposed(by: self._disposeBag)
    }
    
    private func endLoadData() {
        self._isLoadingMore = false
        self._tableView.refreshControl?.endRefreshing()
    }
    
    private func setLoadMoreIndicator(isShow: Bool) {
        if isShow {
            self._loadMoreIndicatorView.isHidden = false
            self._loadMoreIndicatorView.startAnimating()
            self._tableView.tableFooterView = self._loadMoreIndicatorView
        } else {
            self._isLoadingMore = false
            self._loadMoreIndicatorView.isHidden = true
            self._loadMoreIndicatorView.stopAnimating()
            self._loadMoreIndicatorView.removeFromSuperview()
            self._tableView.tableFooterView = nil
        }
    }

    @objc func didPullRefreshData() {
        self.setLoadMoreIndicator(isShow: true)
        self._pullToRefreshSub.onNext(())
    }
    
    func bindTableView() {
        //do something
    }
}

extension MobileDataUsageViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let isNeedLoad: Bool = offsetY > contentHeight - scrollView.frame.size.height
        if isNeedLoad,
            !self._isLoadingMore,
            self._tableView.tableFooterView != nil {
            
            self._isLoadingMore = true
            self._loadMoreSub.onNext(())
        }
    }
    
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let sectionItem = self._dataSource?.sectionModels[indexPath.section].items[indexPath.row] else { return UITableView.automaticDimension }

        guard case let MobileDataUsageSectionItem.yearlyDataUsage(item: model) = sectionItem else { return UITableView.automaticDimension }

        guard let cachedCellHeight = model.cellHeight else { return UITableView.automaticDimension }

        return cachedCellHeight
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let sectionItem = self._dataSource?.sectionModels[indexPath.section].items[indexPath.row] else { return }

        guard case let MobileDataUsageSectionItem.yearlyDataUsage(item: model) = sectionItem else { return }

        guard model.cellHeight == nil else { return }

        model.cellHeight = cell.frame.size.height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let sectionItem = self._dataSource?.sectionModels[indexPath.section].items[indexPath.row] else { return UITableView.automaticDimension }

        guard case let MobileDataUsageSectionItem.yearlyDataUsage(item: model) = sectionItem else { return UITableView.automaticDimension }

        guard let cachedCellHeight = model.cellHeight else { return UITableView.automaticDimension }

        return cachedCellHeight
    }
}

//MARK: - Setup views & layout
extension MobileDataUsageViewController {
    fileprivate func setupViews() {
        self.title = "Mobile Data Usage"
        self.view.backgroundColor = UIColor.black
        self._tableView.refreshControl = self._pullRefreshControl
        self.view.addSubview(self._tableView)
        self.setLoadMoreIndicator(isShow: true)
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

