//
//  GradientButton.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 07/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import UIKit

@IBDesignable
class BorderButton: UIButton {
    
    @IBInspectable
    var cornerRadius: Int = 0 {
        didSet {
            self.layer.cornerRadius = CGFloat( cornerRadius )
        }
    }
    
    @IBInspectable
    var borderWidth: Int = 1 {
        didSet {
            self.layer.borderWidth = CGFloat( borderWidth )
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = UIColor.blue {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
}
