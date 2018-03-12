//
//  NoteTableViewController.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 12/03/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import UIKit
import CoreData

class NoteTableViewController: UITableViewController {

    var notes: [Note] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewNote))
        
        // Fetch Request
        let viewMOC = DataManager.shared.persistentContainer.viewContext
        
        /* Opción 1 */
        // 1.- Creamos el objeto.
        let fetchRequest = NSFetchRequest<Note>()
        
        // 2.- Que entidad es de la que queremos objeto.
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Note", in: viewMOC)
        
        /* Opción 2
         let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        */
        
        // 3.- (Opcional) Queremos un orden? -> Añadir sort description.
        let sortByDate = NSSortDescriptor(key: "createdAtTI", ascending: true)
        let sortByTittle = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortByDate, sortByTittle]
        
        // 4.- (Opcional) Filtrado.
        let created24H = Date().timeIntervalSince1970 - 24*3600
        let predicate = NSPredicate(format: "createdAtTI > %f", created24H)
        fetchRequest.predicate = predicate
        
        // 5.- Ejecutar request.
        do {
           try notes = viewMOC.fetch(fetchRequest)
        } catch {
            print(error)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // NotificationCenter.default.addObserver(tableView, selector: #selector(reloadData), name: NSNotification.Name( NSManagedObjectContextObjectsDidChangeNotification ), object: nil)
        tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier") ??
            UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifier")

        cell.textLabel?.text = notes[indexPath.row].title
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let noteVC = NoteViewByCodeController()
        noteVC.note = notes[indexPath.row]
        navigationController?.pushViewController(noteVC, animated: true)
    }

    @objc func addNewNote() {
        let privateMOC = DataManager.shared.persistentContainer.newBackgroundContext()
        
        privateMOC.perform {
            let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: privateMOC) as! Note
            
            note.title = "New Note - \(self.notes.count + 1)"
            note.createdAtTI = Date().timeIntervalSince1970
            
            do {
                try privateMOC.save()
            } catch {
                
            }
        
            DispatchQueue.main.async {
                let viewNote = DataManager.shared.persistentContainer.viewContext.object(with: note.objectID) as! Note
                
                self.notes.append(viewNote)
                self.tableView.reloadData()
            }
        }
    }
}
