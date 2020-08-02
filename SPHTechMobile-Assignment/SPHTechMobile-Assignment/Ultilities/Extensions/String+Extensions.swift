//
//  String+Extensions.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 8/1/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func size(withSystemFontSize pointSize: CGFloat) -> CGSize {
        return (self as NSString).size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: pointSize)])
    }
}
