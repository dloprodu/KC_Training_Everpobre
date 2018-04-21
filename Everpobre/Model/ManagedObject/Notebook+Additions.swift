//
//  Notebook+Additions.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 08/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import Foundation
import CoreData

extension Notebook {
    
    static func createDefaultIfNotExist() {
        let backMOC = DataManager.shared.persistentContainer.newBackgroundContext()
        
        backMOC.perform {
            let fetchRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
            fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Notebook", in: backMOC)
            
            let predicate = NSPredicate(format: "isDefault == %@", NSNumber(value: true))
            fetchRequest.predicate = predicate
            
            fetchRequest.fetchLimit = 1
            fetchRequest.fetchBatchSize = 5
            
            var notebooks: [Notebook] = []
            
            do {
                try notebooks = backMOC.fetch(fetchRequest)
            } catch {
                print(error)
            }
            
            if (notebooks.count > 0) {
                return
            }
            
            let defaultNotebook = NSEntityDescription.insertNewObject(forEntityName: "Notebook", into: backMOC) as? Notebook
            
            defaultNotebook?.isDefault = true
            defaultNotebook?.name = "My notebook"
            defaultNotebook?.createdAtTI = Date().timeIntervalSince1970
            // defaultNotebook?.setValuesForKeys(dic)
            
            do {
                try backMOC.save()
            } catch {
                
            }
        }
    }
    
    static func getDefault(in moc: NSManagedObjectContext) -> Notebook? {
        let fetchRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Notebook", in: moc)
        
        let predicate = NSPredicate(format: "isDefault == %@", NSNumber(value: true))
        fetchRequest.predicate = predicate
        
        fetchRequest.fetchLimit = 1
        fetchRequest.fetchBatchSize = 5
        
        var notebooks: [Notebook] = []
        
        do {
            try notebooks = moc.fetch(fetchRequest)
        } catch {
            print(error)
        }
        
        return notebooks.count > 0 ? notebooks[0] : nil
    }
    
    static func getAll(in moc: NSManagedObjectContext) -> [Notebook] {
        let fetchRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Notebook", in: moc)
        
        let sortByNotebookDefault = NSSortDescriptor(key: "isDefault", ascending: false)
        let sortByNotebookName = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
        fetchRequest.sortDescriptors = [sortByNotebookDefault, sortByNotebookName]
        
        fetchRequest.fetchBatchSize = 50
        
        var notebooks: [Notebook] = []
        
        do {
            try notebooks = moc.fetch(fetchRequest)
        } catch {
            print(error)
        }
        
        return notebooks
    }
    
    static func create(name: String?) {
        let backMOC = DataManager.shared.persistentContainer.newBackgroundContext()
        
        backMOC.perform {
            let notebook = NSEntityDescription.insertNewObject(forEntityName: "Notebook", into: backMOC) as! Notebook
            
            notebook.name = name ?? "New notebook"
            notebook.createdAtTI = Date().timeIntervalSince1970
            notebook.isDefault = false
            
            do {
                try backMOC.save()
            } catch { }
        }
    }
    
    static func delete(_ notebook: Notebook, target: Notebook?) {
        let backMOC = DataManager.shared.persistentContainer.newBackgroundContext()
        backMOC.perform {
            let backNotebook = backMOC.object(with: notebook.objectID) as! Notebook
            
            if let t = target {
                let backTarget = backMOC.object(with: t.objectID) as! Notebook
                backNotebook.notes?.forEach { ( $0 as? Note)?.notebook = backTarget }
            }
            
            backMOC.delete(backNotebook)
            do {
                try backMOC.save()
            } catch { }
        }
    }
    
    static func makeDefault(_ notebook: Notebook) {
        if (notebook.isDefault) {
            return
        }
        
        let backMOC = DataManager.shared.persistentContainer.newBackgroundContext()
        
        backMOC.perform {
            let backCurentDefault = Notebook.getDefault(in: backMOC)
            let backNewDefault = backMOC.object(with: notebook.objectID) as! Notebook
            
            backCurentDefault?.isDefault = false
            backNewDefault.isDefault = true
            
            do {
                try backMOC.save()
            } catch { }
        }
    }
    
    func update(name: String) {
        if (self.name == name) {
            return
        }
        
        let backMOC = DataManager.shared.persistentContainer.newBackgroundContext()
        let format: DateFormatter = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        backMOC.perform {
            let backNotebook = backMOC.object(with: self.objectID) as! Notebook
            
            if name.isEmpty {
                let date = Date(timeIntervalSince1970: backNotebook.createdAtTI)
                backNotebook.name = format.string(from: date)
            } else {
                backNotebook.name = name
            }
            
            do {
                try backNotebook.managedObjectContext?.save()
            } catch {
                print(error)
            }
        }
    }
}
