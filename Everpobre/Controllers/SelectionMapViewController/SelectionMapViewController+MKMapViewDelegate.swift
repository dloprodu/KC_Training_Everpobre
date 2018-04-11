//
//  SelectionMapViewController+.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 11/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

extension SelectionMapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        /*
        let centerCoord = mapView.centerCoordinate
        
        let location = CLLocation(latitude: centerCoord.latitude, longitude: centerCoord.longitude)
        
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location) { (placeMarkArray, error) in
            
            if let places = placeMarkArray {
                
                if let place = places.first {
                    
                    DispatchQueue.main.async
                        {
                            if let postalAdd = place.postalAddress
                            {
                                self.textField.text =  "\(postalAdd.street) ,  \(postalAdd.city)"
                            }
                    }
                }
            }
        }
        */
    }

}
