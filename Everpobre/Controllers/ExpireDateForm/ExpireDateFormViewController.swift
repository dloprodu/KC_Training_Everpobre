//
//  ExpireDateFormViewController.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 13/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import UIKit

protocol ExpireDateFormViewControllerDelegate: class {
    // should, will, did
    func expireDateFormViewController (_ viewController: ExpireDateFormViewController, didSelectData: Date?)
}

class ExpireDateFormViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // MARK: - Properties
    
    let date: Date?
    weak var delegate: ExpireDateFormViewControllerDelegate?
    
    // MARK: - Initialization
    
    init(date: Date?) {
        self.date = date
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
        datePicker.date = date ?? Date()
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
        delegate?.expireDateFormViewController(self, didSelectData: date)
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func save() {
        delegate?.expireDateFormViewController(self, didSelectData: datePicker.date)
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func remove() {
        delegate?.expireDateFormViewController(self, didSelectData: nil)
        
        dismiss(animated: true, completion: nil)
    }
}
