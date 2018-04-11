//
//  NoteViewController.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 10/03/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import UIKit
import MapKit

// Constraints for UIImageView and MKMapView
class NoteMediaElement<Element> where Element: UIView {
    let element: Element
    let top: NSLayoutConstraint
    let bottom: NSLayoutConstraint
    let left: NSLayoutConstraint
    let right: NSLayoutConstraint
    let constraints: [NSLayoutConstraint]
    
    init(container: UIView, reference: UIView) {
        element = Element()
        element.translatesAutoresizingMaskIntoConstraints = false
        element.isUserInteractionEnabled = true
        
        top = NSLayoutConstraint(item: element, attribute: .top, relatedBy: .equal, toItem: reference, attribute: .top, multiplier: 1, constant: 20)
        
        bottom = NSLayoutConstraint(item: element, attribute: .bottom, relatedBy: .equal, toItem: reference, attribute: .bottom, multiplier: 1, constant: -20)
        
        left = NSLayoutConstraint(item: element, attribute: .left, relatedBy: .equal, toItem: reference, attribute: .left, multiplier: 1, constant: 20)
        
        right = NSLayoutConstraint(item: element, attribute: .right, relatedBy: .equal, toItem: reference, attribute: .right, multiplier: 1, constant: -20)
        
        constraints = [
            NSLayoutConstraint(item: element, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 150),
            NSLayoutConstraint(item: element, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 150),
            top,
            bottom,
            left,
            right
        ]
        
        container.addSubview(element)
        container.addConstraints(constraints)
        
        NSLayoutConstraint.deactivate([bottom,right])
    }
}

class NoteViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var fromDateLabel: UILabel!
    @IBOutlet weak var toDateLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var headerStackView: UIStackView!
    
    // MARK: - Properties
    
    let formatter: DateFormatter
    var note: Note?

    var mapView: NoteMediaElement<MKMapView>?
    var annotation: MKPointAnnotation?

    var pictures: [NoteMediaElement<UIImageView>]?
    
    // MARK: - Initialization
    
    init(model: Note?) {
        self.note = model
        self.formatter = DateFormatter()
        self.formatter.dateFormat = "dd.MM.yyyy"
        
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
        
        title = "Detail"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.delegate = self
        contentTextView.delegate = self
        
        navigationController?.isToolbarHidden = false
        
        let photoBarButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(catchPhoto))
        
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let mapBarButton = UIBarButtonItem(title: "Map", style: .done, target: self, action: #selector(addLocation))
        
        self.setToolbarItems([photoBarButton,flexible,mapBarButton], animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        updateContetnExclusionPath()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
            self.updateContetnExclusionPath()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleTextField.becomeFirstResponder()
        self.syncModelWithView()
    }
    
    // MARK: - Helpers
    
    func syncModelWithView() {
        fromDateLabel.text = self.formatter.string(from: Date(timeIntervalSince1970: TimeInterval(self.note?.createdAtTI ?? 0)))
        
        toDateLabel.text = "--.--.----"
        if let expiration = note?.expirationAtTI {
            if expiration != 0 {
                toDateLabel.text = self.formatter.string(from: Date(timeIntervalSince1970: TimeInterval(expiration)))
            }
        }
        
        titleTextField.text = self.note?.title
        contentTextView.text = self.note?.content
        
        updateMapLocation()
    }
    
    func updateMapLocation() {
        if note?.lat == 0 && note?.long == 0 {
            return
        }
        
        if mapView == nil {
            mapView = NoteMediaElement<MKMapView>(container: self.mainStackView, reference: contentTextView)
        }
        
        let coord = CLLocationCoordinate2D(latitude: note?.lat ?? 0, longitude: note?.long ?? 0)
        
        if annotation != nil {
            self.mapView?.element.removeAnnotation(annotation!)
        }
        
        self.annotation = MKPointAnnotation()
        self.annotation?.coordinate = coord;
        self.mapView?.element.addAnnotation(self.annotation!)
    }
    
    func updateContetnExclusionPath() {
        if let mapView = self.mapView {
            var rect = self.mainStackView.convert(mapView.element.frame, to: contentTextView)
            rect = rect.insetBy(dx: -15, dy: -15)
            
            let paths = UIBezierPath(rect: rect)
            self.contentTextView.textContainer.exclusionPaths = [paths]
        }
        
        // TODO: pictures
    }
}
