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
        note?.title = textField.text
        
        do {
            try note?.managedObjectContext?.save()
        } catch {
            
        }
    }
}

