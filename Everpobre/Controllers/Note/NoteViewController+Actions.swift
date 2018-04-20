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
        let expireDate: Date = (note?.expirationAtTI == 0)
            ? Date()
            : Date(timeIntervalSince1970: note?.expirationAtTI ?? 0)
        
        let expireDateForm = ExpireDateFormViewController(date: expireDate)
        expireDateForm.delegate = self
        present(expireDateForm.wrappedInNavigation(), animated: true, completion: nil)
    }
}
