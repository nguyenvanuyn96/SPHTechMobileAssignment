//
//  MobileDataUsageEmptyTableViewCell.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 8/1/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation
import SnapKit
import Reusable

@objcMembers
class MobileDataUsageEmptyTableViewCell: UITableViewCell, Reusable {
    private lazy var _emptyIconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "ic_mascot_empty_list")
        
        return view
    }()
    
    private lazy var _descriptionLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        view.numberOfLines = 0
        view.lineBreakMode = .byTruncatingTail
        view.textColor = UIColor.lightGray
        view.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        
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
        
        self.contentView.addSubview(_emptyIconImageView)
        self.contentView.addSubview(_descriptionLabel)    }
    
    fileprivate func setupLayout() {
        self._emptyIconImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(80)
            make.height.equalTo(160)
            make.centerX.equalToSuperview()
            make.width.equalTo(148)
        }
        
        self._descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self._emptyIconImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(16)
            make.width.lessThanOrEqualTo(400).priority(.required)
            make.bottom.lessThanOrEqualToSuperview().offset(-18)
        }
    }
    
    func configCell(emptyDescription description: String) {
        self._descriptionLabel.text = description
    }
    
    override public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        //do nothing
    }
    
    override public func setSelected(_ selected: Bool, animated: Bool) {
        //do nothing
    }
}


