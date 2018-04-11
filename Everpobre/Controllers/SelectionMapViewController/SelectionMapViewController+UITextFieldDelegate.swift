//
//  SelectionMapViewController+UITextFieldDelegate.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 11/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import Contacts

extension SelectionMapViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        mapView.isScrollEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.text != nil && !textField.text!.isEmpty {
            mapView.isScrollEnabled = false
            
            let geocoder = CLGeocoder()
            let postalAddress = CNMutablePostalAddress()
            
            postalAddress.street = textField.text!
            // postalAddress.subAdministrativeArea
            // postalAddress.subLocality
            postalAddress.isoCountryCode = "ES"
            
            geocoder.geocodePostalAddress(postalAddress) { (placeMarkArray, error) in
                
                if placeMarkArray != nil && placeMarkArray!.count > 0
                {
                    let placemark = placeMarkArray?.first
                    
                    DispatchQueue.main.async
                        {
                            let region = MKCoordinateRegion(center:placemark!.location!.coordinate, span: MKCoordinateSpan.init(latitudeDelta: 0.004, longitudeDelta: 0.004))
                            self.mapView.setRegion(region, animated: true)
                    }
                    
                    
                }
                
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
}

