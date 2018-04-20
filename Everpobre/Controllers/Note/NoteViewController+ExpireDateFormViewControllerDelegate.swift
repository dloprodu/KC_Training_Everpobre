//
//  NoteViewController+ExpireDateFormViewControllerDelegate.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 13/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import Foundation
import UIKit

extension NoteViewController : ExpireDateFormViewControllerDelegate {
    func expireDateFormViewController (_ viewController: ExpireDateFormViewController, didSelectData: Date?) {

        guard let date = didSelectData else {
            note?.update(expirationAtTI: 0)
            toDateLabel.text = "--.--.----"
            return
        }
        
        note?.update(expirationAtTI: date.timeIntervalSince1970)
        toDateLabel.text = self.formatter.string(from: date)
    }
}
