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
