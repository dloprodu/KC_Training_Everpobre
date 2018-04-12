//
//  NotePicture+Additions.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 12/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import Foundation
import CoreData

extension NotePicture {
    static func create(picture: Data?, parent: Note) {
        let backMOC = DataManager.shared.persistentContainer.newBackgroundContext()
        
        backMOC.perform {
            let notePicture = NSEntityDescription.insertNewObject(forEntityName: "NotePicture", into: backMOC) as! NotePicture

            notePicture.picture = picture
            notePicture.note = backMOC.object(with: parent.objectID) as? Note
            
            do {
                try backMOC.save()
            } catch { }
        }
    }
}
