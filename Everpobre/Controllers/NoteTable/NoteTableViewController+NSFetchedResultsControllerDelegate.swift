//
//  NoteTableViewController+NSFetchedResultsControllerDelegate.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 09/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import Foundation
import CoreData

extension NoteTableViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // The fetch here should not be necesary but how we have
        // two sort descriptions for the sections, I needed it, in order to
        // work fine whe we upate some note.
        do {
            try fetchResultController.performFetch()
        } catch { }
        
        self.tableView.reloadData()
    }
}
