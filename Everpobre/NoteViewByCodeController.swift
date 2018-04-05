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
        
        // Sync model
        self.syncModelWithView()
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
    }
    
    // MARK: - Helpers
    
    func syncModelWithView() {
        dateLabel.text = self.formatter.string(from: Date(timeIntervalSince1970: TimeInterval(self.note?.createdAtTI ?? 0)))
        // expirationDate.text =
        titleTextField.text = self.note?.title
        noteTextView.text = self.note?.content
        
       // imageView
    }
    
    // MARK: - Actions
    
    @objc func closeKeyboard() {
        if noteTextView.isFirstResponder {
            noteTextView.resignFirstResponder()
        } else if titleTextField.isFirstResponder {
            titleTextField.resignFirstResponder()
        }
    }
    
    @objc func moveImage(tapGesture:UITapGestureRecognizer) {
        if topImgConstraint.isActive {
            if leftImgConstraint.isActive {
                leftImgConstraint.isActive = false
                rightImgConstraint.isActive = true
            } else {
                topImgConstraint.isActive = false
                bottomImgConstraint.isActive = true
            }
        } else {
            if leftImgConstraint.isActive {
                bottomImgConstraint.isActive = false
                topImgConstraint.isActive = true
            } else {
                rightImgConstraint.isActive = false
                leftImgConstraint.isActive = true
            }
        }
        
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func userMoveImage(longPressGesture:UILongPressGestureRecognizer) {
        switch longPressGesture.state {
        case .began:
            closeKeyboard()
            relativePoint = longPressGesture.location(in: longPressGesture.view)
            UIView.animate(withDuration: 0.1, animations: {
                self.imageView.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
            })
            
        case .changed:
            let location = longPressGesture.location(in: noteTextView)
            
            leftImgConstraint.constant = location.x - relativePoint.x
            topImgConstraint.constant = location.y - relativePoint.y
            
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.1, animations: {
                self.imageView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            })
            
        default:
            break
        }
    }
    
    // MARK: Toolbar Buttons actions
    
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
        
        actionSheetAlert.addAction(useCamera)
        actionSheetAlert.addAction(usePhotoLibrary)
        actionSheetAlert.addAction(cancel)
        
        present(actionSheetAlert, animated: true, completion: nil)
    }
    
    @objc func addLocation() {
        
    }
}

// MARK: Navigation Delegate

extension NoteViewByCodeController : NoteTableViewControllerDelegate {
    func noteTableViewController(_ viewController: NoteTableViewController, didSelectNote: Note) {
        self.note = didSelectNote
        self.syncModelWithView()
    }
}

// MARK: Navigation Delegate

extension NoteViewByCodeController : UINavigationControllerDelegate {
}

// MARK: Image Picker Delegate

extension NoteViewByCodeController : UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        imageView.image = image
        
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: Text Field Delegate

extension NoteViewByCodeController : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        note?.title = textField.text
        
        do {
            try note?.managedObjectContext?.save()
        } catch {
            
        }
    }
}
