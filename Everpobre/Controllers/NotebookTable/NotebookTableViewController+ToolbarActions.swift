//
//  NotebookTableViewController+ToolbarActions.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 09/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import Foundation
import UIKit

extension NotebookTableViewController {
    @objc func done() {
        dismiss(animated: true) {
            guard let done = self.didDismiss else { return }
            done()
        }
    }
    
    @objc func addNotebook() {
        Notebook.create(name: "New notebook")
    }
    
    @objc func editTable() {
        tableView.setEditing(true, animated: true)
        navigationItem.rightBarButtonItems?.removeLast()
        navigationItem.rightBarButtonItems?.append(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEditTable)))
    }
    
    @objc func cancelEditTable() {
        tableView.setEditing(false, animated: true)
        navigationItem.rightBarButtonItems?.removeLast()
        navigationItem.rightBarButtonItems?.append(UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTable)))
    }
}
