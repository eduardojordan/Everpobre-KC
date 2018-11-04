//
//  Note+CoreDataProperties.swift
//  EverPobre
//
//  Created by Eduardo on 01/11/2018.
//  Copyright © 2018 Eduardo Jordan Muñoz. All rights reserved.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var creationDate: NSDate?
    @NSManaged public var image: NSData?
    @NSManaged public var lastSeenDate: NSDate?
    @NSManaged public var tags: String?
    @NSManaged public var text: String?
    @NSManaged public var title: String?
    @NSManaged public var location: Location?
    @NSManaged public var notebook: Notebook?

}
