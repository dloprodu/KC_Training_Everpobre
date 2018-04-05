//
//  MasterViewController.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 05/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import UIKit

class MasterViewController: UISplitViewController {

    // MARK: - Properties
    
    let noteTableVC: NoteTableViewController
    let noteTableNavC: UINavigationController
    
    let noteDetailVC: NoteViewByCodeController
    let noteDetailNavC: UINavigationController
    
    // MARK: - Initialization
    
    init() {
        self.noteTableVC = NoteTableViewController()
        self.noteTableNavC = self.noteTableVC.wrappedInNavigation()
        
        self.noteDetailVC = NoteViewByCodeController(model: noteTableVC.lastSelectedNote())
        self.noteDetailNavC = self.noteDetailVC.wrappedInNavigation()
        
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
        
        self.noteTableVC.delegate = self.noteDetailVC
        
        self.viewControllers = [
            self.noteTableNavC,
            self.noteDetailNavC
        ]
        
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

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
            
            if let detailVC = view as? NoteViewByCodeController {
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
