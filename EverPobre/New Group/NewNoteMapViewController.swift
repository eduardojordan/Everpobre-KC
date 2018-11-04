//
//  NewNoteMapViewController.swift
//  EverPobre
//
//  Created by Eduardo on 24/10/18.
//  Copyright © 2018 Eduardo Jordan Muñoz. All rights reserved.
//

import UIKit
import MapKit


class NewNoteMapViewController: UIViewController, UITabBarDelegate, UITabBarControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var mainTabBar: UITabBar!
    var notebook: Notebook
    var notes: [Note]
    
    var coredataStack: CoreDataStack
    var pointsOfInterest: [PointOfInterest] = []
    let locationManager = CLLocationManager()
    
    // MARK: init
    init (notebook: Notebook, coredataStack: CoreDataStack){
        self.notebook = notebook
        self.notes = (notebook.notes?.array as? [Note]) ?? []
        self.coredataStack = coredataStack
        super.init(nibName: nil,bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    let regionRadius: CLLocationDistance = 1000
    
    func centerMap(location:CLLocation){
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(region, animated: true)
        
    }
    
// Mark : life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    locationManager.delegate = self   // revisar por que solicita delegate// Lisrto
    locationManager.requestWhenInUseAuthorization()
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters // Distancia
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
            let latitude = locationManager.location?.coordinate.latitude ?? 0.0
            let longitude = locationManager.location?.coordinate.longitude ?? 0.0
            let initialLocation = CLLocation(latitude:  latitude, longitude: longitude)
            centerMap(location: initialLocation)
        }
    
        
        mapView.delegate = self
        mainTabBar.delegate = self
    
    }
  func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if (item.tag == 1){
            
            
            let tabBarNotes = NewNotesListViewController(notebook: notebook, coreDataStack: coredataStack)
            self.navigationController?.pushViewController(tabBarNotes, animated: false)
            tabBarNotes.title = "Notas"
            
        } else if(item.tag == 2){
            
            
            let tabBarMap = NewNoteMapViewController(notebook: notebook, coredataStack: coredataStack)
           self.navigationController?.pushViewController(tabBarMap, animated: false)
            tabBarMap.title = "Mapa"
        }
    }

    
    
// Mark - Location

    private func updateLocations(notes: [Note]){
        for note in notes{
            if note.location != nil{
                let location = CLLocationCoordinate2D(latitude: note.location?.latitude ?? 0.0, longitude: note.location?.longitude ?? 0.0)
                let ubication = PointOfInterest(name: note.title ?? "", location: location)
                pointsOfInterest.append(ubication)
            }
        }
    }
    
    
}
extension NewNoteMapViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//       if let location = locations.last{
//
//       }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("No pude conseguir la ubicacion del usuario:\(error.localizedDescription)")
    }
}



// MARK. MKMPAP DELEGATE 

extension NewNoteMapViewController: MKMapViewDelegate{
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        print( "rendering")
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        self.updateLocations(notes: notes)
        self.mapView.addAnnotations(pointsOfInterest)
   
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pointOfInterest") as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pointOfInterest")
        } else {
            annotationView?.annotation = annotation
        }
        
        annotationView?.markerTintColor = .red
        annotationView?.titleVisibility = .visible
        annotationView?.subtitleVisibility = .adaptive
        
        return annotationView
    }

}

