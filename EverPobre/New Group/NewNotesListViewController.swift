//
//  NewNotesListViewController.swift
//  EverPobre
//
//  Created by Eduardo on 15/10/18.
//  Copyright © 2018 Eduardo Jordan Muñoz. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class NewNotesListViewController: UIViewController, UITabBarDelegate, UITabBarControllerDelegate {
    
    
     // MARK: IBOutlet
    @IBOutlet weak var mainTabBar: UITabBar!
  
    @IBOutlet weak var collectionView: UICollectionView!
    
    
//    var viewController1 : NewNotesListViewController?
//    var viewController2 : NewNoteMapViewController?
    
    // MARK: Properties
    
    let notebook: Notebook
    let coreDataStack: CoreDataStack!
    
    var notes: [Note] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    let transition = Animator()
    
    // MARK: Init
    
    init(notebook: Notebook, coreDataStack: CoreDataStack) {
        self.notebook = notebook
        self.notes = (notebook.notes?.array as? [Note]) ?? []
        self.coreDataStack = coreDataStack
        super.init(nibName: "NewNotesListViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        title = "Notas"
        self.view.backgroundColor = .white
        
        let nib = UINib(nibName: "NotesListCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "NotesListCollectionViewCell")
        
        collectionView.backgroundColor = .lightGray
        
        let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
 
        self.navigationItem.rightBarButtonItems = [addButtonItem]
        
        
        mainTabBar.delegate = self
    
    
    }

    
    // Mark : TabBar
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
         if (item.tag == 1){
            
       
             let tabBarNotes = NewNotesListViewController(notebook: notebook, coreDataStack: coreDataStack)
             self.navigationController?.pushViewController(tabBarNotes, animated: false)
            tabBarNotes.title = "Notas"

            } else if(item.tag == 2){
            
            
            let tabBarMap = NewNoteMapViewController(notebook: notebook, coredataStack: coreDataStack)
            self.navigationController?.pushViewController(tabBarMap, animated: false)
            tabBarMap.title = "Mapa"
            
        }
        
    }
//---->>>
    //Nota para el Profe.
    // Se que aca en la parte de tabBar me quedo una pequeña chapuzilla que realice en este view y con NewNoteMapView, para resolver! pero se que no esta bien. que solo deberia estar la funcion o alli o acá en este ViewController. Agradeceria me ilustrara un poco el como debio ser resuelta, trate de buscar info para esto pero que va! Algunos me indicaban el realizarlo todo por storyBoard, y otros solo XIB, pero en escasos tutoriales sobre agregar el object tabBar al xib y posterior rootcontroller, y llegado este punto me enrede. ... Si me explicas la solucion de -->( func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem)) <--  de como presentarlo para que funcione este tabbar agradecido.
    // No es urgente pero para mi conocimiento y posterior uso me vendria bien saberlo. Un saludo
    // <<-----
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
       
    }

    
    private func showExportFinishedAlert(_ exportPath: String) {
        let message = "El archivo CSV se encuentra en \(exportPath)"
        let alertController = UIAlertController(title: "Exportacion terminada", message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true)
    }
    
    private func notesFetchRequest(from notebook: Notebook) -> NSFetchRequest<Note> {
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        //fetchRequest.fetchBatchSize = 50
        fetchRequest.predicate = NSPredicate(format: "notebook == %@", notebook)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        
        return fetchRequest
    }
    
    @objc private func addNote() {
        let newNoteVC = NoteDetailsViewController(kind: .new(notebook: notebook), managedContext: coreDataStack.managedContext)
        newNoteVC.delegate = self
        let navVC = UINavigationController(rootViewController: newNoteVC)
        self.present(navVC, animated: true, completion: nil)
    }
    
}

// MARK:- UICollectionViewDataSource

extension NewNotesListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotesListCollectionViewCell", for: indexPath) as! NotesListCollectionViewCell
        cell.configure(with: notes[indexPath.row])
        return cell
    }
    
}

// MARK:- UICollectionViewDelegate

extension NewNotesListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = NoteDetailsViewController(kind: .existing(note: notes[indexPath.row]), managedContext: coreDataStack.managedContext)
        detailVC.delegate = self
        //self.show(detailVC, sender: nil)
        
        // custom animation
        let navVC = UINavigationController(rootViewController: detailVC)
        navVC.transitioningDelegate = self
        present(navVC, animated: true, completion: nil)
        
    }
}

// MARK:- UICollectionViewDelegateFlowLayout

extension NewNotesListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 150)
    }
}

// MARK:- NoteDetailsViewControllerProtocol implementation

extension NewNotesListViewController: NoteDetailsViewControllerProtocol {
    func didSaveNote() {
        self.notes = (notebook.notes?.array as? [Note]) ?? []
    }
}

// MARK:- Custom Animation - UIViewControllerTransitioningDelegate

extension NewNotesListViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let indexPath = (collectionView.indexPathsForSelectedItems?.first!)!
        let cell = collectionView.cellForItem(at: indexPath)
        transition.originFrame = cell!.superview!.convert(cell!.frame, to: nil)
        
        transition.presenting = true
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil
    }
}
