//
//  NotebookTableViewController.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 06/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import UIKit
import CoreData

typealias DidDismiss = ()->()

class NotebookTableViewController: UITableViewController {
    // MARK: - Properties
    
    var fetchResultController: NSFetchedResultsController<Notebook>!
    var didDismiss: DidDismiss?
    
    // MARK: - Initialization
    
    init() {
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
 
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.register(UINib.init(nibName: "NotebookFormCell", bundle: nil), forCellReuseIdentifier: "formCellReuse")
        
        title = "Notebooks"
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
        let fetchRequest = NSFetchRequest<Notebook>()
        
        // 2.- Que entidad es de la que queremos objeto.
        fetchRequest.entity = NSEntityDescription.entity(forEntityName: "Notebook", in: viewMOC)
        
        /* Opción 2
         let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
         */
        
        // 3.- (Opcional) Queremos un orden? -> Añadir sort description.
        let sortByNotebookDefault = NSSortDescriptor(key: "isDefault", ascending: false)
        let sortByNotebookName = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortByNotebookDefault, sortByNotebookName]
        
        // carga en memoria en paquetes de 25 (util para trabajar con listas muy grandes)
        fetchRequest.fetchBatchSize = 25
        
        self.fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewMOC, sectionNameKeyPath: nil, cacheName: nil)
        
        try! fetchResultController.performFetch()
        
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
        return fetchResultController.sections?[section].name ?? "-"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notebook = fetchResultController.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "formCellReuse") as? NotebookFormCell ?? NotebookFormCell()
        
        cell.notebook = notebook
        cell.delegate = self
        cell.selectionStyle = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            let notebook = fetchResultController.object(at: indexPath)
            
            if (notebook.isDefault) {
                self.showNotAllowedToDeleteDefaultAlert()
                return
            }
            
            self.confirmDeleteAction(notebook)
            break
        case .none:
            break
        case .insert:
            break
        }
    }
    
    // MARK: - Helpers
    
    func setupUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNotebook)),
            UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTable))
        ]
    }
    
    func showNotAllowedToDeleteDefaultAlert() {
        let warning = UIAlertController(title: "Remove Notebook", message: "You can not delete the default notebook", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        warning.addAction(okAction)
        
        present(warning, animated: true, completion: nil)
    }
    
    func confirmDeleteAction(_ notebook: Notebook) {
        let confirmDelete = UIAlertController(title: "Remove Notebook", message: "Are you sure you would like to delete \"\(notebook.name!)\" from your library?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { [weak self] (action: UIAlertAction) -> Void in
            self?.selectDeleteOption(notebook)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        confirmDelete.addAction(deleteAction)
        confirmDelete.addAction(cancelAction)
        
        confirmDelete.prepareForIPAD(source: self.view, bartButtonItem: nil, direction: .init(rawValue: 0))
        
        present(confirmDelete, animated: true, completion: nil)
    }
    
    func selectDeleteOption(_ notebook: Notebook) {
        if (notebook.notes?.count == 0) {
            Notebook.delete(notebook, target: nil)
            return
        }
        
        let selectDeleteMode = UIAlertController(title: "Remove Notebook", message: "How do you want to delete \"\(notebook.name!)\" from your library?", preferredStyle: .actionSheet)
        
        let deleteAllAction = UIAlertAction(title: "Delete all notes", style: .destructive, handler: {(action: UIAlertAction) -> Void in
            Notebook.delete(notebook, target: nil)
        })
        let moveNotesAction = UIAlertAction(title: "Move notes to another notebook", style: .destructive, handler: { [weak self] (action: UIAlertAction) -> Void in
            
            let selectNotebook = UIAlertController(title: "Select Notebook", message: "Select target notebook", preferredStyle: .actionSheet)
            
            self?.fetchResultController.fetchedObjects?.forEach({ (el) in
                if el.objectID == notebook.objectID {
                    return
                }
                
                selectNotebook.addAction(UIAlertAction(title: el.name, style: .default, handler: {(action: UIAlertAction) -> Void in
                    Notebook.delete(notebook, target: el)
                }))
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            selectNotebook.addAction(cancelAction)
            
            selectNotebook.prepareForIPAD(source: self!.view, bartButtonItem: nil, direction: .init(rawValue: 0))
            
            self?.present(selectNotebook, animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        selectDeleteMode.addAction(deleteAllAction)
        selectDeleteMode.addAction(moveNotesAction)
        selectDeleteMode.addAction(cancelAction)
        
        selectDeleteMode.prepareForIPAD(source: self.view, bartButtonItem: nil, direction: .init(rawValue: 0))
        
        self.present(selectDeleteMode, animated: true, completion: nil)
    }
}

// MARK: Toolbar Buttons actions

extension NotebookTableViewController {
    @objc func done() {
        dismiss(animated: true) {
            guard let done = self.didDismiss else { return }
            done()
        }
    }

    @objc func addNotebook() {
        Notebook.create(name: "New notebook \( (self.fetchResultController.fetchedObjects?.count ?? 0) + 1  )")
    }
    
    @objc func editTable() {
        tableView.setEditing(true, animated: true)
        navigationItem.rightBarButtonItems?.removeLast()
        navigationItem.rightBarButtonItems?.append(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEditTable)))
    }
    
    @objc func cancelEditTable() {
        tableView.setEditing(false, animated: true)
        navigationItem.rightBarButtonItems?.removeLast()
        navigationItem.rightBarButtonItems?.append(UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTable)))
    }
}

// MARK: NSFetchedResultsControllerDelegate

extension NotebookTableViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
    }
}

// MARK: NotebookFormCellDelegate

extension NotebookTableViewController : NotebookFormCellDelegate {
    func notebookFormCell(_ uiViewCell: NotebookFormCell, didDefault: Notebook) {
        if didDefault.isDefault {
            return
        }
        
        let confirmChangeDefault = UIAlertController(title: "Default notebook", message: "Are you sure you would like to mark \"\(didDefault.name!)\" as default notebook?", preferredStyle: .actionSheet)
        
        let makeDefaultAction = UIAlertAction(title: "Mark as default", style: .default, handler: { (action: UIAlertAction) -> Void in
            
            Notebook.makeDefault(didDefault)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        confirmChangeDefault.addAction(makeDefaultAction)
        confirmChangeDefault.addAction(cancelAction)
        
        confirmChangeDefault.prepareForIPAD(source: self.view, bartButtonItem: nil, direction: .init(rawValue: 0))
        
        present(confirmChangeDefault, animated: true, completion: nil)
    }
}
