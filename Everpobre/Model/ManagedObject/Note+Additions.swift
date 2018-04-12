//
//  Note+Additions.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 08/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import Foundation
import CoreData

extension Note {
    
    static func create(target: Notebook?, title: String?) {
        let backMOC = DataManager.shared.persistentContainer.newBackgroundContext()
        
        backMOC.perform {
            let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: backMOC) as! Note
            
            let dic: [String:Any] = [
                "title": title ?? "New note",
                "createdAtTI": Date().timeIntervalSince1970,
                "content": "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
            ]
            
            //note.title = "New Note"
            //note.createdAtTI = Date().timeIntervalSince1970
            note.setValuesForKeys(dic)
            if let target = target {
                note.notebook = backMOC.object(with: target.objectID) as? Notebook
            } else {
                note.notebook = Notebook.getDefault(in: backMOC)
            }
            
            do {
                try backMOC.save()
            } catch { }
        }
    }
    
    static func delete(_ note: Note) {
        let backMOC = DataManager.shared.persistentContainer.newBackgroundContext()
        backMOC.perform {
            let backNote = backMOC.object(with: note.objectID) as! Note
            
            backMOC.delete(backNote)
            do {
                try backMOC.save()
            } catch { }
        }
    }
    
    func update(title: String, content: String) {
        // TODO
    }
    
    /*
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
     */
}
