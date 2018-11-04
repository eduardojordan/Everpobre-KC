//
//  NotebookListViewController.swift
//  EverPobre
//
//  Created by Eduardo on 9/10/18.
//  Copyright © 2018 Eduardo Jordan Muñoz. All rights reserved.
//

import UIKit
import CoreData

class NotebookListViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalLabel: UILabel!
    
    // MARK: Parameters
    
    var coredataStack: CoreDataStack!
    var infoExport:String = ""
    private var fetchedResultsController: NSFetchedResultsController<Notebook>!
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        //model = deprecated_Notebook.dummyNotebookModel
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        super.viewDidLoad()
        
        let exportButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(exportData(_:)))
        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNotebook))
        navigationItem.rightBarButtonItems = [addButtonItem, exportButtonItem]
        
        
        
        configureSearchController()
        showAll()
        
    }
    
    // MARK: NSFetchedResultsController helper methods
    
    private func getFetchedResultsController(with predicate: NSPredicate = NSPredicate(value: true)) -> NSFetchedResultsController<Notebook> {
        
        let fetchRequest: NSFetchRequest<Notebook> = Notebook.fetchRequest()
        fetchRequest.predicate = predicate
        
        let sort = NSSortDescriptor(key: #keyPath(Notebook.creationDate), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        fetchRequest.fetchBatchSize = 20
        
        return NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coredataStack.managedContext,
            sectionNameKeyPath: #keyPath(Notebook.creationDate),
            cacheName: nil)
    }
    
    private func setNewFetchedResultsController(_ newfrc: NSFetchedResultsController<Notebook>) {
        
        let oldfrc = fetchedResultsController
        if (newfrc != oldfrc) {
            fetchedResultsController = newfrc
            newfrc.delegate = self
            do {
                try fetchedResultsController.performFetch()
            } catch let error as NSError {
                print("COuld not fetch \(error)")
            }
            tableView.reloadData()
        }
    }
    
    // MARK: Helper methods
    
    private func configureSearchController() {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search Notebook"
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
    }
    
 
    
    private func populateTotalLabel(with predicate: NSPredicate = NSPredicate(value: true)) {
        let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Notebook")
        fetchRequest.resultType = .countResultType
        
        fetchRequest.predicate = predicate
        
        do {
            let countResult = try coredataStack.managedContext.fetch(fetchRequest)
            let count = countResult.first!.intValue
            totalLabel.text = "\(count)"
        } catch let error as NSError {
            print("Count not fetch: \(error.description)")
        }
        
    }
    
    @IBAction func addNotebook(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Nuevo Notebook", message: "Añade un nuevo Notebbok", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Grabar", style: .default) { [unowned self] action in
            guard
                let textField = alert.textFields?.first,
                let nameToSave = textField.text
                else { return }
            
            let notebook = Notebook(context: self.coredataStack.managedContext)
            notebook.name = nameToSave
            notebook.creationDate = NSDate()
            
            do {
                try self.coredataStack.managedContext.save()
            } catch let error as NSError {
                print("TODO Error handling: \(error.debugDescription)")
            }
            
            self.showAll()
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .default)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    
    
    @IBAction func exportData(_ sender: Any) {
        self.infoExport = ""
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Notebook")
        //request.returnsObjectsAsFaults = false
        do {
            // Fetch the List of Notebooks
            let result = try coredataStack.managedContext.fetch(request)
            for data in result as! [NSManagedObject] {
                infoExport += "\n Notebook: \(data.value(forKey: "name")  ?? "Unknown") \n Date  \(data.value(forKey: "creationDate") ?? "Unknown")"
                fetchNotesFromNotebook(notebook: data)
            }
            // Request Note of Notebook
            
        } catch {
            print("Failed")
        }
        
        print(infoExport)
        let activityViewController = UIActivityViewController(activityItems: [infoExport], applicationActivities: nil)
        if let popoverPresentationController = activityViewController.popoverPresentationController {
            popoverPresentationController.barButtonItem = (sender as! UIBarButtonItem)
        }
        present(activityViewController, animated: true, completion: nil)
    }
    
    func fetchNotesFromNotebook(notebook: NSManagedObject) {
        let requestNote = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        //Set predicate
        let predicate = NSPredicate(format: "notebook == %@", notebook)
        requestNote.predicate = predicate
        do {
            // Fetch the List of Notes of the Notebook
            let result = try coredataStack.managedContext.fetch(requestNote)
            for data in result as! [NSManagedObject] {
                infoExport += "\n \n Note: \(data.value(forKey: "title") ?? "Unknown"), \n Date \(data.value(forKey: "creationDate") ?? "Unknown"), \n Tags \(data.value(forKey: "tags") ?? ""), \n Text \(data.value(forKey: "text") ?? "")"
                fetchLocationFromNote(note: data)
            }
            
        } catch {
            
            print("Failed")
        }
    }
    
    func fetchLocationFromNote(note: NSManagedObject) {
        let requestLocation = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        //Set predicate
        let predicate = NSPredicate(format: "note == %@", note)
        requestLocation.predicate = predicate
        
        do {
            // Fetch the Location of the Note
            let result = try coredataStack.managedContext.fetch(requestLocation)
            for data in result as! [NSManagedObject] {
                infoExport += "\nLocation of Note: \(data.value(forKey: "latitude") ?? "0") \(data.value(forKey: "longitude") ?? "0")"
                
            }
        } catch {
            
            print("Failed")
        }
    }
    
}



// MARK:- UITableViewDataSource implementation

extension NotebookListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let section = fetchedResultsController.sections else { return 1 }
        return section.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[section] else { return 0 }
        return sectionInfo.numberOfObjects
        //return dataSource.count//model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotebookListCell", for: indexPath) as! NotebookListCell
        //let notebook = dataSource[indexPath.row] as! Notebook
        let notebook = fetchedResultsController.object(at: indexPath)
        
        //cell.configure(with: model[indexPath.row])
        cell.configure(with: notebook)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
 
        
        guard editingStyle == .delete else { return }
        
        let notebookToRemove = fetchedResultsController.object(at: indexPath)
        
        coredataStack.managedContext.delete(notebookToRemove)
        
        do {
            try coredataStack.managedContext.save()
            //tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }

        showAll()
    }
    
}

// MARK:- UITableViewDelegate implementation

extension NotebookListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let notebook = fetchedResultsController.object(at: indexPath)
        let notesListVC = NewNotesListViewController(notebook: notebook, coreDataStack: coredataStack)
        show(notesListVC, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections?[section]
        return sectionInfo?.name
    }
}

// MARK:- UISearchResultsUpdating implmentation

extension NotebookListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, !text.isEmpty {
            //mostramos resultados filtrados
            showFilteredResults(with: text)
        } else {
            // Mostramos todos los resultadosas
            showAll()
        }
    }
    
    private func showFilteredResults(with query: String) {
        
        let predicate = NSPredicate(format: "name CONTAINS[c] %@", query)
        let frc = getFetchedResultsController(with: predicate)
        setNewFetchedResultsController(frc)
        
        populateTotalLabel(with: predicate)
        
    }
    
    private func showAll() {
        
        let frc = getFetchedResultsController()
        setNewFetchedResultsController(frc)
        //fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("COuld not fetch \(error)")
            //dataSource = []
        }
        
        populateTotalLabel()
    }
}

// MARK:- NSFetchedResultsControllerDelegate implementation

extension NotebookListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
