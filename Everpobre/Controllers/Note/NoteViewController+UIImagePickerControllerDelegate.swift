//
//  NoteViewController+UIImagePickerControllerDelegate.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 11/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import Foundation
import UIKit

extension NoteViewController : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        guard let imageData = UIImageJPEGRepresentation(image, 1) else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        guard let note = note else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        NotePicture.create(picture: imageData, parent: note) { notePicture in
            let media = NoteMediaElement<UIImageView>(notePicture, viewController: self, container: self.mainStackView, toItem: self.contentTextView)
            media.item.image = image
            
            self.pictures?.append(media)
            picker.dismiss(animated: true, completion: nil)
        }
    }
}

