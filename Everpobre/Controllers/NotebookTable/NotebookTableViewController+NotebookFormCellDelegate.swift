//
//  NotebookTableViewController+NotebookFormCellDelegate.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 09/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import Foundation
import UIKit

extension NotebookTableViewController : NotebookFormCellDelegate {
    func notebookFormCell(_ uiViewCell: NotebookFormCell, didDefault: Notebook) {
        if didDefault.isDefault {
            return
        }
        
        let confirmChangeDefault = UIAlertController(title: "Default notebook", message: "Are you sure you would like to mark \"\(didDefault.name!)\" as default notebook?", preferredStyle: .actionSheet)
        
        let makeDefaultAction = UIAlertAction(title: "Mark as default", style: .default, handler: { (action: UIAlertAction) -> Void in
            
            Notebook.makeDefault(didDefault)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        confirmChangeDefault.addAction(makeDefaultAction)
        confirmChangeDefault.addAction(cancelAction)
        
        confirmChangeDefault.prepareForIPAD(source: self.view, bartButtonItem: nil, direction: .init(rawValue: 0))
        
        present(confirmChangeDefault, animated: true, completion: nil)
    }
}
