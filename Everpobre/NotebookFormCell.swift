//
//  NotebookFormCell.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 07/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import UIKit
import CoreData

protocol NotebookFormCellDelegate: class {
    func notebookFormCell(_ uiViewCell: NotebookFormCell, didDefault: Notebook)
}

class NotebookFormCell: UITableViewCell {

    let format: DateFormatter
    weak var delegate: NotebookFormCellDelegate?
    
    var notebook: Notebook? {
        didSet {
            guard let model = notebook else {
                return
            }
            
            textField.text = model.name
            
            self.defaultButton.backgroundColor = model.isDefault
                ? UIColor(red: 30.0/255.0, green: 144.0/255.0, blue: 255.0/255.0, alpha: 1)
                : UIColor.clear
        }
    }
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }
    
    @IBOutlet weak var defaultButton: BorderButton!
    
    init() {
        format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        delegate = nil
        super.init(style: .default, reuseIdentifier: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        delegate = nil
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func markAsDefault(_ sender: Any) {
        guard let model = self.notebook else {
            return
        }
        
        delegate?.notebookFormCell(self, didDefault: model)
    }
}

// MARK: UITextFieldDelegate

extension NotebookFormCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (self.notebook?.name == textField.text) {
            return
        }
        
        if textField.text?.isEmpty ?? true {
            let date = Date(timeIntervalSince1970: notebook?.createdAtTI ?? 0)
            notebook?.name = format.string(from: date)
        } else {
            notebook?.name = textField.text
        }
        
        do {
            try notebook?.managedObjectContext?.save()
        } catch {
            print(error)
        }
    }
}