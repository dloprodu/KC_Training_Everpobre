//
//  SelectionInMapViewController.swift
//  ARC_Circles
//
//  Created by Joaquin Perez on 13/03/2018.
//  Copyright © 2018 Joaquin Perez. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Contacts

protocol SelectionMapViewControllerDelegate: class {
    func selectionMapViewControl(_ viewControl: SelectionMapViewController, didSelectionLocation: CLLocationCoordinate2D)
}

class SelectionMapViewController: UIViewController {
    
    // MARK: - Properties
    
    let mapView = MKMapView()
    let textField = UITextField()
    
    weak var delegate: SelectionMapViewControllerDelegate?
    var annotation: MKPointAnnotation?
    
    // MARK: - Initialization
    
    init() {
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
        title = "Select a location"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func loadView() {
        
        let backView = UIView()
        
        backView.addSubview(mapView)
        backView.addSubview(textField)
        textField.backgroundColor = UIColor.init(white: 1, alpha: 0.7)
        
        // MARK: Autolayout.
        mapView.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let dictViews = [
            "mapView" : mapView,
            "textField" : textField
        ]
        
        // Horizontals
        var constraint = NSLayoutConstraint.constraints(withVisualFormat: "|-0-[mapView]-0-|", options: [], metrics: nil, views: dictViews)
        
        constraint.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-20-[textField]-20-|", options: [], metrics: nil, views: dictViews))
        
        // Verticals
        constraint.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[mapView]-0-|", options: [], metrics: nil, views: dictViews))
        
        constraint.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[textField(40)]", options: [], metrics: nil, views: dictViews))
        
        constraint.append(NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal, toItem: backView.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 20))
        
        backView.addConstraints(constraint)
        
        self.view = backView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        mapView.delegate = self
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(addAnnotation))
        mapView.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D.init(latitude: 40.425, longitude: -3.7035), span: MKCoordinateSpan.init(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
        mapView.setRegion(region, animated: false)
    }
    
    // MARK: - Actions
    
    @objc func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: mapView)
        let coord = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        let location = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        let geoCoder = CLGeocoder()
        
        if annotation != nil {
            mapView.removeAnnotation(annotation!)
        }
        
        geoCoder.reverseGeocodeLocation(location) { (placeMarkArray, error) in
            if error != nil {
                self.delegate?.selectionMapViewControl(self, didSelectionLocation: coord)
                return
            }
            
            if let places = placeMarkArray {
                if let place = places.first {
                    DispatchQueue.main.async {
                        if let postalAdd = place.postalAddress {
                            self.annotation = MKPointAnnotation()
                            self.annotation?.coordinate = coord;
                            self.annotation?.title = "\(postalAdd.street), \(postalAdd.city)"
                            self.mapView.addAnnotation(self.annotation!)
                            
                            self.textField.text = self.annotation?.title
                            
                            self.delegate?.selectionMapViewControl(self, didSelectionLocation: coord)
                        } else {
                            self.annotation = MKPointAnnotation()
                            self.annotation?.coordinate = coord;
                            
                            self.delegate?.selectionMapViewControl(self, didSelectionLocation: coord)
                        }
                    }
                }
            }
        }
    }
}
