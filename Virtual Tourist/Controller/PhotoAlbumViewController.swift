//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by X901 on 20/11/2018.
//  Copyright © 2018 X901. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class PhotoAlbumViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
var pin: Pin!
    
    

    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<Photo>!

    
    override func viewDidLoad() {
        super.viewDidLoad()

createAnnotation()
        
        
      print("longitude: \(pin.longitude) - latitude: \(pin.latitude)")
    }
    
    
    @IBAction func newCollectionTapped(_ sender: UIButton) {
        
    }
    
    func createAnnotation(){
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
        self.mapView.addAnnotation(annotation)
        
        
        //zooming to location
        let coredinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07)
        let region = MKCoordinateRegion(center: coredinate, span: span)
        self.mapView.setRegion(region, animated: true)
        
    }
    


}

