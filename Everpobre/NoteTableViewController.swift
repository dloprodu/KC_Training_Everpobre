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

    // MARK: - Properties
    
    // var notes: [Note] = []
    var fetchResultController: NSFetchedResultsController<Note>!
    
    // MARK: - Life Cycle
    
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
        
        // No es necesario con NSFetchedController
        // 5.- Ejecutar request.
        // do {
        //   try notes = viewMOC.fetch(fetchRequest)
        // } catch {
        //    print(error)
        // }
        
        self.fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewMOC, sectionNameKeyPath: nil, cacheName: nil)
        
        try! fetchResultController.performFetch()
        
        fetchResultController.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // return 1
        return fetchResultController.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchResultController.sections?[section].name ?? "-"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return notes.count
        return fetchResultController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier") ??
            UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifier")

        // cell.textLabel?.text = notes[indexPath.row].title
        cell.textLabel?.text = fetchResultController.object(at: indexPath).title
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // let note = notes[indexPath.row]
        let note = fetchResultController.object(at: indexPath)
        let noteVC = NoteViewByCodeController()
        noteVC.note = note
        navigationController?.pushViewController(noteVC, animated: true)
    }

    @objc func addNewNote() {
        let privateMOC = DataManager.shared.persistentContainer.newBackgroundContext()
        
        privateMOC.perform {
            let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: privateMOC) as! Note
            
            note.title = "New Note"
            note.createdAtTI = Date().timeIntervalSince1970
            
            do {
                try privateMOC.save()
            } catch {
                
            }
        
            // Ya no es necesario con NSFetchedController
            //DispatchQueue.main.async {
            //    let viewNote = DataManager.shared.persistentContainer.viewContext.object(with: note.objectID) as! Note
                
            //    self.notes.append(viewNote)
            //    self.tableView.reloadData()
            //}
        }
    }
}

extension NoteTableViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
    }
}
