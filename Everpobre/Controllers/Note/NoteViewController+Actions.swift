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
    
    @objc func changeNotebook() {
        let selectNotebook = UIAlertController(title: "Notebook: \( (note?.notebook?.name ?? "") )", message: "Select target notebook", preferredStyle: .actionSheet)
        
        let notebooks = Notebook.getAll(in: DataManager.shared.persistentContainer.viewContext)
        
        notebooks.forEach({ (el) in
            if el.objectID == self.note?.notebook?.objectID {
                return
            }
            
            selectNotebook.addAction(UIAlertAction(title: el.name, style: .default, handler: {(action: UIAlertAction) -> Void in
                self.note?.update(notebook: el)
            }))
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        selectNotebook.addAction(cancelAction)
        
        selectNotebook.prepareForIPAD(source: self.view, bartButtonItem: self.toolbarItems?.last, direction: .down)
        
        self.present(selectNotebook, animated: true, completion: nil)
    }
}
