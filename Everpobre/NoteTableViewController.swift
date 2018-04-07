//
//  NoteTableViewController.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 12/03/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import UIKit
import CoreData

enum NoteTableViewControllerKeys: String {
    case NoteDidChangeNotificationName
    case LastNote
    case LastSection
    case LastRow
}

protocol NoteTableViewControllerDelegate: class {
    // should, will, did
    func noteTableViewController (_ viewController: NoteTableViewController, didSelectNote: Note)
}

class NoteTableViewController: UITableViewController {

    // MARK: - Properties
    
    weak var delegate: NoteTableViewControllerDelegate?
    var fetchResultController: NSFetchedResultsController<Note>!
    
    // MARK: - Initialization
    
    init() {
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
        
        title = "Notes"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let sortByNotebookDefault = NSSortDescriptor(key: "notebook.isDefault", ascending: true)
        let sortByNotebookName = NSSortDescriptor(key: "notebook.name", ascending: true)
        let sortByDate = NSSortDescriptor(key: "createdAtTI", ascending: true)
        let sortByTittle = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortByNotebookDefault, sortByNotebookName, sortByDate, sortByTittle]
        
        // 4.- (Opcional) Filtrado.
        let created24H = Date().timeIntervalSince1970 - 24*3600
        let predicate = NSPredicate(format: "createdAtTI > %f", created24H)
        fetchRequest.predicate = predicate
        
        // carga en memoria en paquetes de 25 (util para trabajar con listas muy grandes)
        fetchRequest.fetchBatchSize = 25
        
        // No es necesario con NSFetchedController
        // 5.- Ejecutar request.
        // do {
        //   try notes = viewMOC.fetch(fetchRequest)
        // } catch {
        //    print(error)
        // }
        
        self.fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewMOC, sectionNameKeyPath: "notebook.name", cacheName: nil)
        
        try! fetchResultController.performFetch()
        
        fetchResultController.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupUI()
        self.restoreLastSelection()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
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
        let note = fetchResultController.object(at: indexPath)
        let collapsed = splitViewController?.isCollapsed ?? true
        
        if collapsed {
            self.navigationController?.pushViewController(NoteViewByCodeController(model: note), animated: true)
        } else {
            delegate?.noteTableViewController(self, didSelectNote: note)
        }
        
        let notification = Notification(name: Notification.Name(NoteTableViewControllerKeys.NoteDidChangeNotificationName.rawValue),
            object: self,
            userInfo: [NoteTableViewControllerKeys.LastNote.rawValue: note])
        
        NotificationCenter.default.post(notification)
        
        // Guardar las coordenadas (section, row) de la última casa seleccionada
        saveLastSelectedNote(at: indexPath)
    }
    
    // MARk: - Helpers
    
    func setupUI() {
        // Add Note button
        // navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewNote))
        
        // Managage notebooks button
        navigationController?.isToolbarHidden = false
        
        let addNoteButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewNote))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let notebookButton = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(showNotebooks))
        
        self.setToolbarItems([addNoteButton, flexible, notebookButton], animated: false)
    }
    
    func restoreLastSelection() {
        // Select last note selected
        /* TODO
        if (fetchResultController.fetchedObjects?.count == 0) {
            return
        }
        
        let section = UserDefaults.standard.integer(forKey: NoteTableViewControllerKeys.LastSection.rawValue)
        let row = UserDefaults.standard.integer(forKey: NoteTableViewControllerKeys.LastRow.rawValue)
        let indexPath = IndexPath(item: row, section: section)
        
        self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        
        let note = fetchResultController.object(at: indexPath)
        let collapsed = splitViewController?.isCollapsed ?? true
        
        if !collapsed {
            delegate?.noteTableViewController(self, didSelectNote: note)
        }
        */
    }
}

// MARK: Toolbar Buttons actions

extension NoteTableViewController {
    @objc func addNewNote() {
        let privateMOC = DataManager.shared.persistentContainer.newBackgroundContext()
        
        privateMOC.perform {
            let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: privateMOC) as! Note
            
            let dic: [String:Any] = [
                "title": "New Note \( (self.fetchResultController.fetchedObjects?.count ?? 0) + 1 )",
                "createdAtTI": Date().timeIntervalSince1970,
                "content": "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda."
            ]
            
            //note.title = "New Note"
            //note.createdAtTI = Date().timeIntervalSince1970
            note.setValuesForKeys(dic)
            if let defaultNotebook = DataManager.shared.getDefaultNotebook(in: privateMOC) {
                note.notebook = defaultNotebook
            }
            
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
    
    @objc func showNotebooks() {
        let navVC = NotebookTableViewController().wrappedInNavigation()
        navVC.modalPresentationStyle = .overCurrentContext
        self.present(navVC, animated: true) {}
    }
}

// MARK: NSFetchedResultsControllerDelegate

extension NoteTableViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
    }
}

// MARK: Save last selection

extension NoteTableViewController {
    func saveLastSelectedNote(at indexPath: IndexPath) {
        let defaults = UserDefaults.standard
        defaults.set(indexPath.section, forKey: NoteTableViewControllerKeys.LastRow.rawValue)
        defaults.set(indexPath.row, forKey: NoteTableViewControllerKeys.LastRow.rawValue)
        defaults.synchronize()
    }
    
    func lastSelectedNote() -> Note? {
        let sections = fetchResultController?.sections?.count ?? 0
        
        if (sections == 0) {
            return nil
        }
        
        let section = UserDefaults.standard.integer(forKey: NoteTableViewControllerKeys.LastSection.rawValue)
        let row = UserDefaults.standard.integer(forKey: NoteTableViewControllerKeys.LastRow.rawValue)
        
        let note = fetchResultController.object(at: IndexPath(row: row, section: section))
        
        return note
    }
}
