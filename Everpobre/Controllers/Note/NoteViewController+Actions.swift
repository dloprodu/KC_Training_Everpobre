//
//  NoteViewController+Actions.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 11/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import Foundation
import UIKit

extension NoteViewController {
    
    @objc func closeKeyboard() {
        if contentTextView.isFirstResponder {
            contentTextView.resignFirstResponder()
        } else if titleTextField.isFirstResponder {
            titleTextField.resignFirstResponder()
        }
    }
    
    @objc func selectExpireDate() {
        guard let note = note else {
            return
        }
        
        let expireDateForm = ExpireDateFormViewController(note: note)
        expireDateForm.delegate = self
        present(expireDateForm.wrappedInNavigation(), animated: true, completion: nil)
    }
}
