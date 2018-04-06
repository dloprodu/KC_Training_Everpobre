//
//  NotebookTableViewController.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 06/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import UIKit
import CoreData

class NotebookTableViewController: UITableViewController {
    // MARK: - Properties
    
    var fetchResultController: NSFetchedResultsController<Notebook>!
    
    // MARK: - Initialization
    
    init() {
        super.init(nibName: nil, bundle: Bundle(for: type(of: self)))
        
        title = "Notebooks"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
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
        let sortByNotebookDefault = NSSortDescriptor(key: "isDefault", ascending: true)
        let sortByNotebookName = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortByNotebookDefault, sortByNotebookName]
        
        // carga en memoria en paquetes de 25 (util para trabajar con listas muy grandes)
        fetchRequest.fetchBatchSize = 25
        
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
        cell.textLabel?.text = fetchResultController.object(at: indexPath).name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    // MARK: Toolbar Buttons actions
    
    @objc func done() {
        dismiss(animated: true, completion: nil)
    }
}

extension NotebookTableViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
    }
}
