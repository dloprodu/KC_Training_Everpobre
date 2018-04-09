//
//  NoteViewByCodeController.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 11/03/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import UIKit

class NoteViewByCodeController: UIViewController  {
    
    // MARK: - Subviews
    
    let formatter: DateFormatter
    
    let dateLabel = UILabel()
    let expirationDate = UILabel()
    let titleTextField = UITextField()
    let noteTextView = UITextView()
    
    let imageView = UIImageView()
    
    var topImgConstraint: NSLayoutConstraint!
    var bottomImgConstraint: NSLayoutConstraint!
    var leftImgConstraint: NSLayoutConstraint!
    var rightImgConstraint: NSLayoutConstraint!
    
    var relativePoint: CGPoint!
    
    // MARK: - Properties
    
    var note: Note?
    
    // MARK: - Initialization
    
    init(model: Note?) {
        self.note = model
        self.formatter = DateFormatter()
        self.formatter.dateFormat = "yyyy/MM/dd"
        
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
        
        title = "Detail"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func loadView() {
        
        let backView = UIView()
        backView.backgroundColor = .white
        
        // Configure label
        dateLabel.text = "----/--/--"
        backView.addSubview(dateLabel)
        
        // Configure Expiration label
        expirationDate.text = "----/--/--"
        backView.addSubview(expirationDate)
        
        
        // Configure textField
        titleTextField.placeholder = "Title note"
        backView.addSubview(titleTextField)
        
        // Configure noteTextView
        noteTextView.text = "..."
        
        backView.addSubview(noteTextView)
        
        // Configure imageView
        imageView.backgroundColor = .red
        backView.addSubview(imageView)
        
        // MARK: Autolayout.
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        expirationDate.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        /*
         class func constraints(withVisualFormat format: String,
         options opts: NSLayoutFormatOptions = [],
         metrics: [String : Any]?,
         views: [String : Any]) -> [NSLayoutConstraint]
         */
        
        let viewDict = ["dateLabel":dateLabel,"noteTextView":noteTextView,"titleTextField":titleTextField,"expirationDate":expirationDate]
        
        // Horizontals
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "|-10-[titleTextField]-10-[expirationDate]-10-[dateLabel]-10-|", options: [], metrics: nil, views: viewDict)
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-10-[noteTextView]-10-|", options: [], metrics: nil, views: viewDict))
        
        // Verticals
        
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:[dateLabel]-10-[noteTextView]-10-|", options: [], metrics: nil, views: viewDict))
        
        constraints.append(NSLayoutConstraint(item: dateLabel, attribute: .top, relatedBy: .equal, toItem: backView.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 10))
        
        
        // Option A
        // dateLabel.topAnchor.constraint(equalTo: backView.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        
        // Option B, less to explain.
        
        //    constraints.append(NSLayoutConstraint(item: dateLabel, attribute: .top, relatedBy: .equal, toItem: backView.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 10))
        
        constraints.append(NSLayoutConstraint(item: titleTextField, attribute: .lastBaseline, relatedBy: .equal, toItem: dateLabel, attribute: .lastBaseline, multiplier: 1, constant: 0))
        
        constraints.append(NSLayoutConstraint(item: expirationDate, attribute: .lastBaseline, relatedBy: .equal, toItem: dateLabel, attribute: .lastBaseline, multiplier: 1, constant: 0))
        
        // Img View Constraint.
        
        topImgConstraint = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: noteTextView, attribute: .top, multiplier: 1, constant: 20)
        
        bottomImgConstraint = NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: noteTextView, attribute: .bottom, multiplier: 1, constant: -20)
        
        leftImgConstraint = NSLayoutConstraint(item: imageView, attribute: .left, relatedBy: .equal, toItem: noteTextView, attribute: .left, multiplier: 1, constant: 20)
        
        rightImgConstraint = NSLayoutConstraint(item: imageView, attribute: .right, relatedBy: .equal, toItem: noteTextView, attribute: .right, multiplier: 1, constant: -20)
        
        var imgConstraints = [NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 100)]
        
        imgConstraints.append(NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 150))
        
        imgConstraints.append(contentsOf: [topImgConstraint,bottomImgConstraint,leftImgConstraint,rightImgConstraint])
        
        
        backView.addConstraints(constraints)
        backView.addConstraints(imgConstraints)
        
        NSLayoutConstraint.deactivate([bottomImgConstraint,rightImgConstraint])
        
        self.view = backView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Delegates
        titleTextField.delegate = self
        
        // Navigation Controller
        navigationController?.isToolbarHidden = false
        
        let photoBarButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(catchPhoto))
                
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let mapBarButton = UIBarButtonItem(title: "Map", style: .done, target: self, action: #selector(addLocation))
        
        self.setToolbarItems([photoBarButton,flexible,mapBarButton], animated: false)
        
        // Gestures
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(closeKeyboard))
        swipeGesture.direction = .down
        
        view.addGestureRecognizer(swipeGesture)
        
        imageView.isUserInteractionEnabled = true
        
        //        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(moveImage))
        //
        //        doubleTapGesture.numberOfTapsRequired = 2
        //
        //        imageView.addGestureRecognizer(doubleTapGesture)
        
        let moveViewGesture = UILongPressGestureRecognizer(target: self, action: #selector(userMoveImage))
        
        imageView.addGestureRecognizer(moveViewGesture)
    }
    
    override func viewDidLayoutSubviews() {
        var rect = view.convert(imageView.frame, to: noteTextView)
        rect = rect.insetBy(dx: -15, dy: -15)
        
        let paths = UIBezierPath(rect: rect)
        noteTextView.textContainer.exclusionPaths = [paths]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        titleTextField.becomeFirstResponder()
        // Sync model
        self.syncModelWithView()
    }
    
    // MARK: - Helpers
    
    func syncModelWithView() {
        dateLabel.text = self.formatter.string(from: Date(timeIntervalSince1970: TimeInterval(self.note?.createdAtTI ?? 0)))
        // expirationDate.text =
        titleTextField.text = self.note?.title
        noteTextView.text = "\( (self.note?.notebook?.name ?? "") ) - \( (self.note?.content ?? "") )"
        
       // imageView
    }
}
