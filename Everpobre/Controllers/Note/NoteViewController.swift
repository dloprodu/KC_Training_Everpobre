//
//  NoteViewController.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 10/03/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import UIKit
import MapKit

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
        self.pictures = [NoteMediaElement<UIImageView>]()
        
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
        
        // Gestures
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(closeKeyboard))
        swipeGesture.direction = .down
        
        view.addGestureRecognizer(swipeGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
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
        
        if (self.pictures?.count == 0) {
            note?.pictures?.forEach({ (notePicture) -> Void in
                let media = NoteMediaElement<UIImageView>(self, container: self.mainStackView, toItem: self.contentTextView)
                media.item.image = UIImage(data: (notePicture as! NotePicture).picture!)
                self.pictures?.append(media)
            })
        }
        
        updateMapLocation()
    }
    
    func updateMapLocation() {
        if note?.lat == 0 && note?.long == 0 {
            return
        }
        
        if mapView == nil {
            mapView = NoteMediaElement<MKMapView>(self, container: self.mainStackView, toItem: contentTextView)
        }
        
        let coord = CLLocationCoordinate2D(latitude: note?.lat ?? 0, longitude: note?.long ?? 0)
        
        if annotation != nil {
            self.mapView?.item.removeAnnotation(annotation!)
        }
        
        self.annotation = MKPointAnnotation()
        self.annotation?.coordinate = coord;
        self.mapView?.item.addAnnotation(self.annotation!)
    }
    
    func updateContetnExclusionPath() {
        var paths = [UIBezierPath]()
        
        if let mapView = self.mapView {
            var rect = self.mainStackView.convert(mapView.item.frame, to: contentTextView)
            rect = rect.insetBy(dx: -15, dy: -15)
            paths.append( UIBezierPath(rect: rect) )
        }
        
        pictures?.forEach({ (picture) in
            var rect = self.mainStackView.convert(picture.item.frame, to: contentTextView)
            rect = rect.insetBy(dx: -15, dy: -15)
            paths.append( UIBezierPath(rect: rect) )
        })
        
        self.contentTextView.textContainer.exclusionPaths = paths
    }
}
