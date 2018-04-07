//
//  NotebookFormCell.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 07/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import UIKit

class NotebookFormCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var isDefault: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
