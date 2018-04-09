//
//  NotebookFormCell+UITextFieldDelegate.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 09/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import Foundation
import UIKit

extension NotebookFormCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let notebook = self.notebook else {
            return
        }
        
        guard let name = textField.text else {
            return
        }
        
        notebook.update(name: name)
    }
}
