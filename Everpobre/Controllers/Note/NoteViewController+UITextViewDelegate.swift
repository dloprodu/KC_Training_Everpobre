//
//  NoteViewController+UITextViewDelegate.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 11/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import Foundation
import UIKit

extension NoteViewController : UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        note?.content = textView.text
        
        do {
            try note?.managedObjectContext?.save()
        } catch {
            
        }
    }
}

