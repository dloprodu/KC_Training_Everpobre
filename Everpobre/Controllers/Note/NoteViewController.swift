//
//  NoteViewController.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 10/03/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import UIKit

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
    
    let imageView = UIImageView()
    
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
        var rect = view.convert(imageView.frame, to: contentTextView)
        rect = rect.insetBy(dx: -15, dy: -15)
        
        let paths = UIBezierPath(rect: rect)
        contentTextView.textContainer.exclusionPaths = [paths]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleTextField.becomeFirstResponder()
        self.syncModelWithView()
    }
    
    // MARK: - Helpers
    
    func syncModelWithView() {
        fromDateLabel.text = self.formatter.string(from: Date(timeIntervalSince1970: TimeInterval(self.note?.createdAtTI ?? 0)))
        
        if let expiration = note?.expirationAtTI {
            toDateLabel.text = self.formatter.string(from: Date(timeIntervalSince1970: TimeInterval(expiration)))
        } else {
            toDateLabel.text = "--.--.----"
        }
        
        titleTextField.text = self.note?.title
        contentTextView.text = self.note?.content
        
        // imageView
    }
}
