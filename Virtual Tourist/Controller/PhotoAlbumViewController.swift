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
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

var pin: Pin!
    
    var photosArray = [String]()
    

    var dataController:DataController!
    
    @IBOutlet weak var noImageLable: UILabel!
    
    var fetchedResultsController:NSFetchedResultsController<Photo>!

    
    override func viewDidLoad() {
        super.viewDidLoad()

createAnnotation()
setFlowLayout()
        getPhotosFromFlikr()
    
    }
    
    func getPhotosFromFlikr(){
        FlickrClient.sharedInstance().getPhotosFormFlicker(latitude: pin.latitude, longitude: pin.longitude, { (success, photoData,NoPhotoMessage, errorString)  in
            
            if success {
                
                if NoPhotoMessage == nil {
                    
                    DispatchQueue.main.async {
                        self.noImageLable.isHidden = true
                    }
                    
                    if let photo = photoData as? [PhotoParse] {
                        
                        for i in photo {
                            self.photosArray.append(i.url_m)
                        }
                        
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                        }
                    }
                }else {
                    DispatchQueue.main.async {
                        self.noImageLable.isHidden = false
                        self.noImageLable.text = NoPhotoMessage
                    }
                }
                
                
            }
        })
    }

    func setFlowLayout(){
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    
    @IBAction func newCollectionTapped(_ sender: UIButton) {
        photosArray.removeAll()
        getPhotosFromFlikr()

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
    
    func updateUI(cell:PhotoAlbumCollectionViewCell, status:Bool) {
        
        if status == false {
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
            
        } else {
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.isHidden = true
            
        }
        }

    
    
  


}


extension PhotoAlbumViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if photosArray.count != 0 {
            return photosArray.count
        } else {
            return 0;
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photosCell", for: indexPath) as! PhotoAlbumCollectionViewCell

        updateUI(cell: cell, status: false)
        if (!photosArray.isEmpty) {
            
            guard let url = URL(string: photosArray[indexPath.row]) else {return cell}
            
            let dataTask = URLSession.shared.dataTask(with: url) {
                data, response, error in
                if error == nil {
                    if let data = data {
                        let image = UIImage(data: data)
                        
                        print("Downloaded: " + url.absoluteString)
                        
                        DispatchQueue.main.async {
                            cell.imageFlikr.image = image!
                            self.updateUI(cell: cell, status: true)

                        }
                    }
                } else {
                    print(error)
                }
            }
            dataTask.resume()
        } else {

        }
        
        return cell

    }
    
    
}
