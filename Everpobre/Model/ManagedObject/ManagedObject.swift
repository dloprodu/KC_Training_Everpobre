//
//  ManagedObject.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 13/03/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import Foundation

extension Note {
    override public func setValue(_ value: Any?, forUndefinedKey key: String) {
        let keyToIgnore = ["date", "content"]
        
        if (keyToIgnore.contains(key)) {
            // ignore
        } else if key == "main_title" {
            self.setValue(value, forKey: "title")
        } else {
            super.setValue(value, forKey: key)
        }
    }
    
    public override func value(forUndefinedKey key: String) -> Any? {
        if key == "main_title" {
            return "main_title"
        } else {
            return super.value(forUndefinedKey: key)
        }
    }
}
