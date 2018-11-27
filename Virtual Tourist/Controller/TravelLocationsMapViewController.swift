//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by X901 on 18/11/2018.
//  Copyright © 2018 X901. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var dataController:DataController!
    var annotations = [MKAnnotation]()
    var pinSelected: Pin!
    
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    
    fileprivate func setUpFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "PinData")
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        }catch{
            fatalError("The fetch could not be performed : \(error.localizedDescription)")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longGesture = UILongPressGestureRecognizer(target: self, action:
            #selector(longTap(_:)))
        mapView.addGestureRecognizer(longGesture)
        setUpFetchedResultsController()
        showPinsOnMapWhenAppStart()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpFetchedResultsController()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    //toPhotoAlbum
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "toPhotoAlbum" ) {
            if let vc = segue.destination as? PhotoAlbumViewController {
                
                vc.dataController = dataController
                vc.pin = pinSelected
                
            }
        }
        
        
    }
    
    
    func showPinsOnMapWhenAppStart(){
        
        //this will display last pin added !
        //i'm not sure why the last pin added on begin of the aray ! , but it's working fine
        if let lastPin = fetchedResultsController.fetchedObjects?.first {
            zoomToLastPin(lastPin: lastPin)
            
        }
        
        
        for location in fetchedResultsController.fetchedObjects! {
            
            let latitude = location.latitude
            let longitude = location.longitude
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            self.annotations.append(annotation)
            
        }
        DispatchQueue.main.async {
            self.mapView.addAnnotations(self.annotations)
            
        }
        
    }
    
    
    func zoomToLastPin(lastPin:Pin){
        
        
        //zooming to location
        let coredinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lastPin.coordinate.latitude, lastPin.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0)
        let region = MKCoordinateRegion(center: coredinate, span: span)
        self.mapView.setRegion(region, animated: true)
        
    }
    
    
    @objc func longTap(_ sender: UIGestureRecognizer){
        if sender.state == .ended {
            
            //Do Whatever You want on End of Gesture
            let touchLocation = sender.location(in: mapView)
            let coordinate = mapView.convert(touchLocation,
                                             toCoordinateFrom: mapView)
 
            addPinToCoreData(latitude: coordinate.latitude, longitude: coordinate.longitude)

        }
        
    }
    
    
    func addPinToCoreData(latitude: Double ,longitude: Double) {
        let pin = Pin(context: dataController.viewContext)
        
        pin.latitude = latitude
        pin.longitude = longitude
        pin.creationDate = Date()
        
        do
        {
            try dataController.viewContext.save()
        }
        catch
        {
            //ERROR
            print(error)
        }
    }
    
    
}

extension TravelLocationsMapViewController : NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        
        guard let pin = anObject as? Pin else {
            preconditionFailure("All changes observed in the map view controller should be for Point instances")
        }
        
        
        switch type {
        case .insert:
            DispatchQueue.main.async {
                self.mapView.addAnnotation(pin)
            }
            
        case .delete:
            mapView.removeAnnotation(pin)
            
        case .update:
            mapView.removeAnnotation(pin)
            mapView.addAnnotation(pin)
            
        case .move: break
            
        }
    }
}


extension Pin: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        
        let latDegrees = CLLocationDegrees(latitude)
        let longDegrees = CLLocationDegrees(longitude)
        return CLLocationCoordinate2D(latitude: latDegrees, longitude: longDegrees)
        
    }
}


extension TravelLocationsMapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        
        let annotation = view.annotation
        let annotationLat = annotation?.coordinate.latitude
        let annotationLong = annotation?.coordinate.longitude
        if let result = fetchedResultsController.fetchedObjects {
            for pin in result {
                if pin.latitude == annotationLat && pin.longitude == annotationLong {
                    pinSelected = pin
                    performSegue(withIdentifier: "toPhotoAlbum", sender: self)
                    
                    break
                }
            }
            
            
            
            
        }
        

        
    }
    
}

