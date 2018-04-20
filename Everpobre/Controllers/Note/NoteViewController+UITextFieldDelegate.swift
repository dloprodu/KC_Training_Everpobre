//
//  NoteViewController+UITextFieldDelegate.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 11/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import Foundation
import UIKit

extension NoteViewController : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.note?.update(title: textField.text)
    }
}

