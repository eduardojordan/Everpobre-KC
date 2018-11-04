//
//  CoreDataStack.swift
//  EverPobre
//
//  Created by Eduardo on 9/10/18.
//  Copyright © 2018 Eduardo Jordan Muñoz. All rights reserved.
//



// ESTE CODIGO FUE APORTADO POR EL INSTRUCTOR

// CUANDO CREAMOS UN PROYECTO E INDICAMOS COREDATA ESTO LO INCLUYE EN APPDELGATE

import Foundation
import CoreData

class CoreDataStack {
    
    private let modelName: String
    
    
    lazy var managedContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    
    lazy var backgroundContex : NSManagedObjectContext = {
        return self.storeContainer.newBackgroundContext()
    }()
    
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
   /* private */ lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Unresolved  error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func saveContext() {
        guard managedContext.hasChanges else { return }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
}
