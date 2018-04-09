//
//  UIAlertController+Additions.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 08/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    func prepareForIPAD(source: UIView, bartButtonItem: UIBarButtonItem?, direction: UIPopoverArrowDirection) {
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            self.popoverPresentationController?.barButtonItem = bartButtonItem
            self.popoverPresentationController?.permittedArrowDirections = direction
            self.popoverPresentationController?.sourceView = source
            self.popoverPresentationController?.sourceRect = CGRect(x: source.bounds.midX, y: source.bounds.midY, width: 0, height: 0)
        }
    }
}
