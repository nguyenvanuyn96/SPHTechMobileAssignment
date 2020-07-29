//
//  BaseWireframeProtocol.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 7/30/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation

protocol BaseWireframeProtocol: class {
    func goBack()
    func goBack(completion: (()->Void)?)
    func goBack(animated: Bool)
    func goBack(animated: Bool, completion: (()->Void)?)
}

extension BaseWireframeProtocol {
    func goBack() {
        
    }
    
    func goBack(completion: (()->Void)?) {
        
    }
    
    func goBack(animated: Bool) {
        
    }
    
    func goBack(animated: Bool, completion: (()->Void)?) {
        
    }
}
