//
//  NoteViewController+SelectionMapViewControllerDelegate.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 13/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import Foundation
import CoreLocation

extension NoteViewController: SelectionMapViewControllerDelegate {
    func selectionMapViewControl(_ viewControl: SelectionMapViewController, didSelectionLocation: CLLocationCoordinate2D) {
        self.note?.update(lat: didSelectionLocation.latitude, long: didSelectionLocation.longitude)
        self.updateMapLocation()
    }
}
