//
//  ExpireDateFormViewController.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 13/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import UIKit
import UserNotifications

protocol ExpireDateFormViewControllerDelegate: class {
    // should, will, did
    func expireDateFormViewController (_ viewController: ExpireDateFormViewController, didSelectData: Date?)
}

class ExpireDateFormViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // MARK: - Properties
    
    let note: Note
    let expireDate: Date
    weak var delegate: ExpireDateFormViewControllerDelegate?
    
    // MARK: - Initialization
    
    init(note: Note) {
        self.note = note
        self.expireDate = (note.expirationAtTI == 0)
            ? Date()
            : Date(timeIntervalSince1970: note.expirationAtTI)
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
        
        title = "Limit Date"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.minimumDate = Date()
        datePicker.date = expireDate
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Helpers
    
    func setupUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save)),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(remove))
        ]
    }
    
    // MARK: - Actions
    
    @objc func cancel() {
        delegate?.expireDateFormViewController(self, didSelectData: expireDate)
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func save() {
        delegate?.expireDateFormViewController(self, didSelectData: datePicker.date)
        
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: note.title ?? "", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: note.content ?? "", arguments: nil)  
        content.sound = UNNotificationSound.default()
        
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: datePicker.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: "NoteExpireDateNotification", content: content, trigger: trigger)
        
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                print(error)
            }
        })
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func remove() {
        delegate?.expireDateFormViewController(self, didSelectData: nil)
        
        dismiss(animated: true, completion: nil)
    }
}
