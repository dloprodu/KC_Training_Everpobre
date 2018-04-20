//
//  NoteViewController+ToolbarActions.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 11/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import UIKit
import MapKit

extension NoteViewController {
    @objc func catchPhoto() {
        let actionSheetAlert = UIAlertController(title: NSLocalizedString("Add photo", comment: "Add photo"), message: nil, preferredStyle: .actionSheet)
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let useCamera = UIAlertAction(title: "Camera", style: .default) { (alertAction) in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        let usePhotoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (alertAction) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .destructive, handler: nil)
        
        actionSheetAlert.prepareForIPAD(source: self.view, bartButtonItem: self.toolbarItems?.first, direction: .down)
        actionSheetAlert.addAction(useCamera)
        actionSheetAlert.addAction(usePhotoLibrary)
        actionSheetAlert.addAction(cancel)
        
        present(actionSheetAlert, animated: true, completion: nil)
    }
    
    @objc func addLocation() {
        let coord = CLLocationCoordinate2D(latitude: note?.lat ?? 0, longitude: note?.long ?? 0)
        let mapView = SelectionMapViewController(coord)
        mapView.delegate = self
        
        present(mapView.wrappedInNavigation(), animated: true, completion: nil)
    }
}
