//
//  NotesListCollectionViewCell.swift
//  EverPobre
//
//  Created by Eduardo on 15/10/18.
//  Copyright © 2018 Eduardo Jordan Muñoz. All rights reserved.
//

import UIKit
import CoreLocation

class NotesListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var creationDateLabel: UILabel!
    
    // Agregar etiquetas de la celda
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    
   // let locationManager = CLLocationManager()
    @IBOutlet weak var imageCell: UIImageView!

    
    var item: Note!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with item: Note) {
        backgroundColor = .white
   
        imageCell.image = UIImage(data: item.image! as Data)
        titleLabel.text = item.title
        creationDateLabel.text = (item.creationDate as Date?)?.customStringLabel()
        latitudeLabel.text = "\((item.location?.latitude) ?? 0.0)"
        longitudeLabel.text = "\((item.location?.longitude) ?? 0.0)"
       
    }
}
