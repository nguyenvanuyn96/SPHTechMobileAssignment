//
//  MobileDataUsageYearlyDataTableViewCell.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 8/1/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation
import SnapKit
import Reusable

@objcMembers
class MobileDataUsageYearlyDataTableViewCell: UITableViewCell, Reusable {
    private var _data: MobileYearlyDataUsageModel?
    public var onTapViewChartButton: ((MobileYearlyDataUsageModel) -> Void)?
    
    private lazy var _containerView: UIView = {
        let view = UIView()
//        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 12
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.borderWidth = 1
        
        return view
    }()
    
    private lazy var _yearLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        view.textColor = UIColor.white
        view.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        view.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        
        return view
    }()
    
    private lazy var _chartButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "chart_icon")?.withTintColor(UIColor.lightGray), for: .normal)
        view.addTarget(self, action: #selector(didTapChartButton), for: .touchUpInside)
        view.touchAreaEdgeInsets = UIEdgeInsets(top: -30, left: -30, bottom: -30, right: -30)
        
        return view
    }()
    
    private lazy var _yearTotalAmountTitleLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        view.textColor = UIColor.lightGray
        view.text = "TOTAL AMOUNT"
        view.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        view.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        
        return view
    }()
    
    private lazy var _yearTotalAmountLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.font = UIFont.systemFont(ofSize: 40, weight: .semibold)
//        view.textColor = UIColor.white
        view.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        view.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        
        return view
    }()
    
    private lazy var _yearTotalAmountUnitLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .left
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        view.textColor = UIColor.white
        view.text = "PETABYTES"
        view.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        view.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        view.setContentCompressionResistancePriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
        view.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.vertical)
        
        return view
    }()
    
    private lazy var _upDownStatusImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    private lazy var _dataStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .leading
        view.axis = .vertical
        view.spacing = 16
        
        return view
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupViews()
        self.setupLayout()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func setupViews() {
        self.contentView.backgroundColor = UIColor.systemBackground
        
        self.contentView.addSubview(self._containerView)
        self._containerView.addSubview(self._yearLabel)
        self._containerView.addSubview(self._chartButton)
        self._containerView.addSubview(self._yearTotalAmountTitleLabel)
        self._containerView.addSubview(self._yearTotalAmountLabel)
        self._containerView.addSubview(self._yearTotalAmountUnitLabel)
        self._containerView.addSubview(self._upDownStatusImageView)
        self._containerView.addSubview(self._dataStackView)
        
    }
    
    fileprivate func setupLayout() {
        self._containerView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-6)
        }
        
        self._yearLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(24)
        }
        
        self._upDownStatusImageView.snp.makeConstraints { (make) in
            make.leading.equalTo(self._yearLabel.snp.trailing).offset(12)
            make.centerY.equalTo(self._yearLabel)
            make.height.width.equalTo(14)
        }
        
        self._chartButton.snp.makeConstraints { (make) in
            make.top.equalTo(self._yearLabel)
            make.trailing.equalToSuperview().offset(-16)
            make.height.width.equalTo(20)
            make.leading.greaterThanOrEqualTo(self._upDownStatusImageView.snp.trailing).offset(12)
        }
        
        self._yearTotalAmountTitleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalTo(self._containerView.snp.centerX).offset(40)
            make.top.equalTo(self._yearLabel.snp.bottom).offset(16)
            make.height.equalTo(24)
        }
        
        self._yearTotalAmountLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalTo(self._containerView.snp.centerX).offset(40)
            make.top.equalTo(self._yearTotalAmountTitleLabel.snp.bottom).offset(8)
            make.height.equalTo(36)
        }
        
        self._yearTotalAmountUnitLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(self._yearTotalAmountLabel)
            make.trailing.equalTo(self._yearTotalAmountLabel)
            make.top.equalTo(self._yearTotalAmountLabel.snp.bottom).offset(8)
            make.height.equalTo(28)
            make.bottom.lessThanOrEqualToSuperview().offset(-12)
        }
        
        self._dataStackView.snp.makeConstraints { (make) in
            make.top.equalTo(self._yearTotalAmountLabel)
            make.leading.equalTo(self._containerView.snp.centerX)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.lessThanOrEqualToSuperview().offset(-16)
        }
    }
    
    func configCell(data: MobileYearlyDataUsageModel) {
        self._data = data
        self._yearLabel.text = "\(data.year)"
        self._yearTotalAmountLabel.text = "\(data.totalAmount)"
        var statusImage: UIImage?
        if data.isDecrease {
            statusImage = UIImage(named: "down_status_icon")?.withTintColor(UIColor.red)
        } else {
            statusImage = UIImage(named: "up_status_icon")?.withTintColor(UIColor.green)
        }
        self._upDownStatusImageView.image = statusImage
        
        for arrangedSubviewItem in self._dataStackView.arrangedSubviews {
            arrangedSubviewItem.removeFromSuperview()
        }

        for recordItem in data.records {
            if let recordViewItem = self.createQuarterRecordItemView(with: recordItem) {
                self._dataStackView.addArrangedSubview(recordViewItem)
            }
        }
    }
    
    @objc func didTapChartButton() {
        guard let data = self._data else { return }
        
        self.onTapViewChartButton?(data)
    }
    
    override public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        //do nothing
    }
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        //do nothing
    }
    
    private func createQuarterRecordItemView(with record: Record) -> UIView? {
        guard let quarterNumber = record.quarterNumber else { return nil }
            
        let titleLabel: UILabel = {
            let view = UILabel()
            view.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)
            view.textColor = UIColor.lightGray
            view.textAlignment = .left
            view.numberOfLines = 1
            view.lineBreakMode = .byTruncatingTail
            
            return view
        }()
        
        let volumeLabel: UILabel = {
            let view = UILabel()
            view.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
            view.textColor = UIColor.white
            view.textAlignment = .left
            view.numberOfLines = 1
            view.lineBreakMode = .byTruncatingTail
            
            return view
        }()
        
        let downStatusImageView: UIImageView = {
            let view = UIImageView(image: UIImage(named: "down_status_icon")?.withTintColor(UIColor.red))
            view.contentMode = .scaleAspectFit
            view.isHidden = true
            
            return view
        }()
        
        let containerView: UIView = {
            let view = UIView()
            
            return view
        }()
        
        containerView.addSubview(downStatusImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(volumeLabel)
        
        downStatusImageView.snp.makeConstraints { (make) in
            make.height.width.equalTo(14)
            make.leading.equalToSuperview().offset(32)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(downStatusImageView.snp.trailing).offset(4)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(40)
        }
        
        volumeLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel.snp.trailing)
            make.trailing.lessThanOrEqualToSuperview()
            make.centerY.equalTo(titleLabel)
        }
        
        titleLabel.text = "Q\(quarterNumber)".uppercased()
        volumeLabel.text = "\(record.volume)"
        
        return containerView
    }
}



