//
//  NoteViewController+NoteTableViewControllerDelegate.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 11/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import Foundation

extension NoteViewController : NoteTableViewControllerDelegate {
    func noteTableViewController(_ viewController: NoteTableViewController, didSelectNote: Note) {
        self.note = didSelectNote
        
        self.pictures = []
        self.mapView = nil
        
        self.syncModelWithView()
    }
    
    func noteTableViewController(_ viewController: NoteTableViewController, didDeleteNote: Note) {
        if self.note?.objectID == didDeleteNote.objectID {
            self.note = nil
            self.syncModelWithView()
        }
    }
}
