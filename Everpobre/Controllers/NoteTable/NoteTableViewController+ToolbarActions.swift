//
//  NoteTableViewController+ToolbarActions.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 09/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import Foundation
import UIKit

extension NoteTableViewController {
    
    @objc func addNewNote() {
        Note.create(target: nil, title: "New note")
    }
    
    @objc func showNotebooks() {
        let notebookVC = NotebookTableViewController()
        notebookVC.didDismiss = {
            do {
                try self.fetchResultController.performFetch()
            } catch { }
            
            self.tableView.reloadData()
        }
        
        let navVC = notebookVC.wrappedInNavigation()
        navVC.modalPresentationStyle = .overCurrentContext
        
        self.present(navVC, animated: true) { }
    }
    
    @objc func selectNotebook() {
        let notebooks = Notebook.getAll(in: DataManager.shared.persistentContainer.viewContext)
        
        let selectNotebook = UIAlertController(title: "Select Notebook", message: "Select target notebook", preferredStyle: .actionSheet)
        
        notebooks.forEach({ (el) in
            selectNotebook.addAction(UIAlertAction(title: el.name, style: .default, handler: {(action: UIAlertAction) -> Void in
                Note.create(target: el, title: "New note")
            }))
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        selectNotebook.addAction(cancelAction)
        
        selectNotebook.prepareForIPAD(source: self.view, bartButtonItem: self.toolbarItems?.first, direction: .down)
        
        self.present(selectNotebook, animated: true, completion: nil)
    }
}
