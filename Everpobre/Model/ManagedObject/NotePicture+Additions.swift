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
    static func create(picture: Data?, parent: Note, completion: @escaping (NotePicture)->Void) {
        let backMOC = DataManager.shared.persistentContainer.newBackgroundContext()
        
        backMOC.perform {
            let backNotePicture = NSEntityDescription.insertNewObject(forEntityName: "NotePicture", into: backMOC) as! NotePicture

            backNotePicture.picture = picture
            backNotePicture.note = backMOC.object(with: parent.objectID) as? Note
            
            do {
                try backMOC.save()
            } catch { }
            
            DispatchQueue.main.async {
                let moc = DataManager.shared.persistentContainer.viewContext
                
                let notePictrue = moc.object(with: backNotePicture.objectID) as! NotePicture
                completion(notePictrue)
            }
        }
    }
    
    func update(locationX x: Float, y: Float, scale: Float, rotation: Float) {
        let backMOC = DataManager.shared.persistentContainer.newBackgroundContext()
        
        backMOC.perform {
            let backNotepicture = backMOC.object(with: self.objectID) as! NotePicture
            
            backNotepicture.locationX = x
            backNotepicture.locationY = y
            backNotepicture.scale = scale
            backNotepicture.rotation = rotation
            
            do {
                try backMOC.save()
            } catch {
                print(error)
            }
        }
    }
}
