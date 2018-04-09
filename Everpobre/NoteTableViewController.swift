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
    var lastSelectionRestored: Bool = false
    var notes: [[Note]]
    
    // MARK: - Initialization
    
    init() {
        notes = [[Note]]()
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
        let sortByNotebookName = NSSortDescriptor(key: "notebook.name", ascending: true)
        let sortByDate = NSSortDescriptor(key: "createdAtTI", ascending: true)
        fetchRequest.sortDescriptors = [ sortByNotebookName, sortByDate ]
        
        // 4.- (Opcional) Filtrado.
        //let created24H = Date().timeIntervalSince1970 - 24*3600
        //let predicate = NSPredicate(format: "createdAtTI > %f", created24H)
        //fetchRequest.predicate = predicate
        
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
        
        do {
            try fetchResultController.performFetch()
        } catch { }
        
        fetchResultController.delegate = self
        loadNotes()
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
        // return fetchResultController.sections?.count ?? 1
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // return fetchResultController.sections?[section].name ?? "-"
        return notes[section][0].notebook?.name
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return fetchResultController.sections?[section].numberOfObjects ?? 0
        return notes[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier") ??
            UITableViewCell(style: .default, reuseIdentifier: "reuseIdentifier")

        // cell.textLabel?.text = fetchResultController.object(at: indexPath).title
        cell.textLabel?.text = notes[indexPath.section][indexPath.row].title
        //cell.accessoryType = .disclosureIndicator
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            // let note = fetchResultController.object(at: indexPath)
            let note = notes[indexPath.section][indexPath.row]
            
            let confirmDelete = UIAlertController(title: "Remove note", message: "Are you sure you would like to delete \"\(note.title!)\" from your library?", preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { (action: UIAlertAction) -> Void in
                Note.delete(note)
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
        //let note = fetchResultController.object(at: indexPath)
        let note = notes[indexPath.section][indexPath.row]
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
    
    // This method help us to set in first position the default notebook and the rest of notebooks in alphabetical order
    func loadNotes() {
        var list = fetchResultController.fetchedObjects ?? []
        list.sort { (a: Note, b: Note) -> Bool in
            if a.notebook?.isDefault == b.notebook?.isDefault {
                return (a.title ?? "") < (b.title ?? "")
            }
            
            if a.notebook?.isDefault ?? false {
                return true
            }
            
            return false
        }
        notes = list.group { $0.notebook?.name ?? "" }
        tableView.reloadData()
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
    
    func restoreLastSelection() {
        if lastSelectionRestored {
            return
        }
        
        lastSelectionRestored = true
        
        if (self.tableView.numberOfSections == 0) {
            return
        }
        
        var section = UserDefaults.standard.integer(forKey: NoteTableViewControllerKeys.LastSection.rawValue)
        if (section >= self.tableView.numberOfSections) {
            section = 0
        }
        
        if (self.tableView.numberOfRows(inSection: section) == 0) {
            return
        }
        
        var row = UserDefaults.standard.integer(forKey: NoteTableViewControllerKeys.LastRow.rawValue)
        if (row >= self.tableView.numberOfRows(inSection: section)) {
            row = 0
        }
        
        let indexPath = IndexPath(item: row, section: section)
        
        self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        
        let note = fetchResultController.object(at: indexPath)
        let collapsed = splitViewController?.isCollapsed ?? true
        
        if !collapsed {
            delegate?.noteTableViewController(self, didSelectNote: note)
        }
    }
}

// MARK: Toolbar Buttons actions

extension NoteTableViewController {
    var newNoteTitle: String {
        return "New note \( (self.fetchResultController.fetchedObjects?.count ?? 0) + 1 )"
    }
    
    @objc func addNewNote() {
        Note.create(target: nil, title: newNoteTitle)
    }
    
    @objc func showNotebooks() {
        let notebookVC = NotebookTableViewController()
        notebookVC.didDismiss = {
            do {
                try self.fetchResultController.performFetch()
            } catch { }
            
            self.loadNotes()
        }
        
        let navVC = notebookVC.wrappedInNavigation()
        navVC.modalPresentationStyle = .overCurrentContext
        
        self.present(navVC, animated: true) { }
    }
    
    @objc func selectNotebook() {
        let notebooks = Notebook.getAll(in: DataManager.shared.persistentContainer.viewContext)
        
        let selectNotebook = UIAlertController(title: "Select Notebook", message: "Select target notebook", preferredStyle: .actionSheet)
        
        notebooks.forEach({ (el) in
            selectNotebook.addAction(UIAlertAction(title: el.name, style: .default, handler: {(action: UIAlertAction) -> Void in
                Note.create(target: el, title: self.newNoteTitle)
            }))
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        selectNotebook.addAction(cancelAction)
        
        selectNotebook.prepareForIPAD(source: self.view, bartButtonItem: self.toolbarItems?.first, direction: .down)
        
        self.present(selectNotebook, animated: true, completion: nil)
    }
}

// MARK: NSFetchedResultsControllerDelegate

extension NoteTableViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.loadNotes()
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
