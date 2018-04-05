//
//  UIViewController+Additions.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 05/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func wrappedInNavigation() -> UINavigationController {
        return UINavigationController(rootViewController: self)
    }
}
