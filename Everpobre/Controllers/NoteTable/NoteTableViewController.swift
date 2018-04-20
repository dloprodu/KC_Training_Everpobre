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
}

protocol NoteTableViewControllerDelegate: class {
    // should, will, did
    func noteTableViewController (_ viewController: NoteTableViewController, didSelectNote: Note)
    func noteTableViewController (_ viewController: NoteTableViewController, didDeleteNote: Note)
}

class NoteTableViewController: UITableViewController {

    // MARK: - Properties
    
    weak var delegate: NoteTableViewControllerDelegate?
    var fetchResultController: NSFetchedResultsController<Note>!
    var lastSelectionRestored: Bool = false
    let formatter: DateFormatter
    
    // MARK: - Initialization
    
    init() {
        formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        super.init(style: .grouped)
        title = "Notes"
        tableView.allowsMultipleSelectionDuringEditing = false
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
        let sortByNotebookDefault = NSSortDescriptor(key: "notebook.isDefault", ascending: false)
        let sortByNotebookName = NSSortDescriptor(key: "notebook.name", ascending: true)
        let sortByDate = NSSortDescriptor(key: "createdAtTI", ascending: true)
        fetchRequest.sortDescriptors = [ sortByNotebookDefault, sortByNotebookName, sortByDate ]
        
        // 4.- (Opcional) Filtrado (NSPredicate).
        
        // Carga en memoria en paquetes de 25 (util para trabajar con listas muy grandes)
        fetchRequest.fetchBatchSize = 25
        
        self.fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewMOC, sectionNameKeyPath: "notebook.name", cacheName: nil)
        
        do {
            try fetchResultController.performFetch()
        } catch { }
        
        fetchResultController.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchResultController.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // return fetchResultController.sections?[section].name ?? "-"
        let note = fetchResultController.object(at: IndexPath(row: 0, section: section))
        
        return note.notebook?.name
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return fetchResultController.sections?[section].numberOfObjects ?? 0
        let note = fetchResultController.object(at: IndexPath(row: 0, section: section))
        
        return note.notebook?.notes?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier") ??
            UITableViewCell(style: .value1, reuseIdentifier: "reuseIdentifier")
        
        guard let note = getNote(at: indexPath) else {
            cell.textLabel?.text = "[error]"
            return cell
        }
        
        cell.textLabel?.text = note.title
        cell.detailTextLabel?.text = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(note.createdAtTI)))
        //cell.accessoryType = .disclosureIndicator
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            guard let note = getNote(at: indexPath) else {
                return
            }
            
            let confirmDelete = UIAlertController(title: "Remove note", message: "Are you sure you would like to delete \"\(note.title!)\" from your library?", preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { (action: UIAlertAction) -> Void in
                Note.delete(note)
                let collapsed = self.splitViewController?.isCollapsed ?? true
                
                if !collapsed {
                    self.delegate?.noteTableViewController(self, didDeleteNote: note)
                }
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            confirmDelete.addAction(deleteAction)
            confirmDelete.addAction(cancelAction)
            
            confirmDelete.prepareForIPAD(source: self.view, bartButtonItem: nil, direction: .init(rawValue: 0))
            
            present(confirmDelete, animated: true, completion: nil)
            break
        case .none:
            break
        case .insert:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let note = getNote(at: indexPath) else {
            return
        }
        
        let collapsed = splitViewController?.isCollapsed ?? true
        
        if collapsed {
            self.navigationController?.pushViewController(NoteViewController(model: note), animated: true)
        } else {
            delegate?.noteTableViewController(self, didSelectNote: note)
        }
        
        let notification = Notification(name: Notification.Name(NoteTableViewControllerKeys.NoteDidChangeNotificationName.rawValue),
            object: self,
            userInfo: [NoteTableViewControllerKeys.LastNote.rawValue: note])
        
        NotificationCenter.default.post(notification)
    }
    
    // MARk: - Helpers
    
    func getNote(at indexPath: IndexPath) -> Note? {
        let first = fetchResultController.object(at: IndexPath(row: 0, section: indexPath.section))
        return first.notebook?.notes?.allObjects[indexPath.row] as? Note ?? nil
    }
    
    func setupUI() {
        navigationController?.isToolbarHidden = false
        
        let button = UIButton(type: .custom)
        button.setTitle("Add note", for: .normal)
        button.setTitleColor(view.tintColor, for: .normal)
        
        let addNoteButton = UIBarButtonItem(customView: button)
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let notebookButton = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(showNotebooks))
        
        self.setToolbarItems([addNoteButton, flexible, notebookButton], animated: false)
        
        // Gestures
        addNoteButton.customView?.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(selectNotebook)))
        addNoteButton.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addNewNote)))
    }
}
