//
//  Location+CoreDataProperties.swift
//  EverPobre
//
//  Created by Eduardo on 01/11/2018.
//  Copyright © 2018 Eduardo Jordan Muñoz. All rights reserved.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var note: Note?

}
