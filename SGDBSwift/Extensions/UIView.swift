//
//  UIView.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 5/30/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import UIKit

extension UIView {
    func addShadow() {
        layer.shadowColor = UIColor.white.cgColor
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 2.0
        layer.cornerRadius = 5.0
        clipsToBounds = true
        layer.masksToBounds = false
        
        subviews.forEach { view in
            view.layer.cornerRadius = 5.0
            view.layer.masksToBounds = true
        }
    }
}
