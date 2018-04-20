//
//  MasterViewController+UISplitViewControllerDelegate.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 09/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import Foundation
import UIKit

extension MasterViewController : UISplitViewControllerDelegate {
    
    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewControllerDisplayMode) {
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        
        // sync views
        // moves stact views from master to detail
        var index = 0;
        var views = [UIViewController]()
        var model: Note?
        self.noteTableNavC.viewControllers.forEach { view in
            if (index > 1) {
                views.append(view)
            }
            
            if let detailVC = view as? NoteViewController {
                model = detailVC.note
            }
            
            index += 1
        }
        
        self.noteTableNavC.popToRootViewController(animated: false)
        self.noteDetailNavC.popToRootViewController(animated: false)
        
        views.forEach { view in
            self.noteDetailNavC.pushViewController(view, animated: false)
        }
        
        // sync models
        if let note = model {
            self.noteDetailVC.note = note
        }
        
        return self.noteDetailNavC
    }
}
