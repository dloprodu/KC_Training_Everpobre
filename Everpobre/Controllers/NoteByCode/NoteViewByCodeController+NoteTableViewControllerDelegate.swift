//
//  NoteViewByCodeController+NoteTableViewControllerDelegate.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 09/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import Foundation
import UIKit

extension NoteViewByCodeController : NoteTableViewControllerDelegate {
    func noteTableViewController(_ viewController: NoteTableViewController, didSelectNote: Note) {
        self.note = didSelectNote
        self.syncModelWithView()
    }
}
