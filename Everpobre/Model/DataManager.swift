//
//  DataManager.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 12/03/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import UIKit
import CoreData

class DataManager: NSObject {
    // MOC: Manager Object Context
    
    static let shared = DataManager()
    
    private var _defaultNotebook: Notebook?
    
    var defaultNotebook: Notebook? {
        return _defaultNotebook
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Everpobre")
        container.loadPersistentStores { (storeDescription: NSPersistentStoreDescription, error: Error?) in
            if let err = error {
                print(err)
            }
            
            container.viewContext.automaticallyMergesChangesFromParent = true
        }
        
        return container
    }()
    
    func createDefaultNotebookIfNotExist() {
        //let fetchRequest = NSFetchRequest<Notebook>()
        let moc = DataManager.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Notebook", in: moc)
        
        let sortByDate = NSSortDescriptor(key: "createdAtTI", ascending: true)
        fetchRequest.sortDescriptors = [sortByDate]
        fetchRequest.fetchBatchSize = 5
        
        var notebooks: [Notebook] = []
        
        do {
            try notebooks = moc.fetch(fetchRequest)
        } catch {
            print(error)
        }
        
        if (notebooks.count > 0) {
            self._defaultNotebook = notebooks[0]
            return
        }
        
        let privateMOC = DataManager.shared.persistentContainer.newBackgroundContext()
        
        privateMOC.perform {
            self._defaultNotebook = NSEntityDescription.insertNewObject(forEntityName: "Notebook", into: privateMOC) as? Notebook
            
            let dic: [String:Any] = [
                "isDefault": true,
                "name": "My notebook",
                "createdAtTI": Date().timeIntervalSince1970
            ]
            
            self._defaultNotebook?.setValuesForKeys(dic)
            
            do {
                try privateMOC.save()
            } catch {
                
            }
        }
    }
    
    func getDefaultNotebook(in moc: NSManagedObjectContext) -> Notebook? {
        let fetchRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Notebook", in: moc)
        
        let sortByDate = NSSortDescriptor(key: "createdAtTI", ascending: true)
        fetchRequest.sortDescriptors = [sortByDate]
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
}
