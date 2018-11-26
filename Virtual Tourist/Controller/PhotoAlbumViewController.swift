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
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var noImageLable: UILabel!

    var pin: Pin!
    
    var photosUrlArray = [URL]()

    
    var selectedCells:NSMutableArray = []
    private var blockOperations: [BlockOperation] = []

    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<Photo>!

    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", self.pin)
    fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()

        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newCollectionButton.isEnabled = false

        getPhotosFromFlikr()

createAnnotation()
setFlowLayout()

        setupFetchedResultsController()
        print(fetchedResultsController.fetchedObjects?.count)


        collectionView.allowsMultipleSelection = true
    
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      setupFetchedResultsController()


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
                            self.photosUrlArray.append(URL(string: i.url_m)!)
                    
                        }
                        
                        self.downloadImagesAndsavaItToPhotoData()

                        
                        print("Number of Photo: \(self.photosUrlArray.count)")

                        
                        
                       

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
       
        if sender.currentTitle == "New Collection" {
            photosUrlArray.removeAll()
            getPhotosFromFlikr()
            
        } else if sender.currentTitle == "Remove Selected Pictures" {
            
            sender.setTitle("New Collection", for: .normal)
            
         deletePhotos()
        

    }
        
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
    
    func downloadImagesAndsavaItToPhotoData(){
        
        if ((fetchedResultsController.fetchedObjects?.isEmpty)!) {
            
            for url in photosUrlArray {
                
                let dataTask = URLSession.shared.dataTask(with: url) {
                    data, response, error in
                    
                    if error == nil {
                        if let data = data {
                            
                            self.addPhotosToCoreData(data:data)

                            
                            
                        }
                        
                    }else {
                        print(error!)
                    }
                    
                }
                dataTask.resume()

            }


            
            
        }
        
    }
    
    func addPhotosToCoreData(data:Data) {
        let photo = Photo(context: dataController.viewContext)

                photo.imageData = data
                photo.creationDate = Date()
                photo.pin = pin
        
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

    
    func deletePhotos() {
//        let noteToDelete = fetchedResultsController.object(at: indexPath)
//        dataController.viewContext.delete(noteToDelete)
//        try? dataController.viewContext.save()
        
        for i in selectedCells {
            photosUrlArray.remove(at: (i as AnyObject).row)
        }
        
        self.collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at : selectedCells as! [IndexPath] )
            
            
        })
        //make Array of selected Cell == 0 after removed items
        selectedCells.removeAllObjects()
        }
        
    deinit {
        // Cancel all block operations when VC deallocates
        for operation: BlockOperation in blockOperations {
            operation.cancel()
        }
        
        blockOperations.removeAll(keepingCapacity: false)
    }

    
        }



extension PhotoAlbumViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        if let sectionInfo = self.fetchedResultsController.sections?[section] {
            return sectionInfo.numberOfObjects
        }
        return 0

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
  
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photosCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        
        cell.selectedView.isHidden = true
        
        self.updateUI(cell: cell, status: false)

        

            let arrayData = self.fetchedResultsController.fetchedObjects!
            cell.imageFlikr.image =  UIImage(data: arrayData[indexPath.row].imageData!)

        
        self.updateUI(cell: cell, status: true)



      
        


        
        return cell

        }


    }
    
    


extension PhotoAlbumViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoAlbumCollectionViewCell

        cell.selectedView.isHidden = false
        selectedCells.add(indexPath)
        newCollectionButton.setTitle("Remove Selected Pictures", for: .normal)

        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoAlbumCollectionViewCell
        
        cell.selectedView.isHidden = true
        selectedCells.remove(indexPath)
        
        if selectedCells.count == 0 {
        newCollectionButton.setTitle("New Collection", for: .normal)
        }
    }
    
}


//Mark : CoreData FetchedResultsController
extension PhotoAlbumViewController:NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        let op: BlockOperation
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            op = BlockOperation { self.collectionView.insertItems(at: [newIndexPath]) }
            
        case .delete:
            guard let indexPath = indexPath else { return }
            op = BlockOperation { self.collectionView.deleteItems(at: [indexPath]) }
        case .move:
            guard let indexPath = indexPath,  let newIndexPath = newIndexPath else { return }
            op = BlockOperation { self.collectionView.moveItem(at: indexPath, to: newIndexPath) }
        case .update:
            guard let indexPath = indexPath else { return }
            op = BlockOperation { self.collectionView.reloadItems(at: [indexPath]) }
        }
        
        blockOperations.append(op)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            self.blockOperations.forEach { $0.start() }
        }, completion: { finished in
            self.blockOperations.removeAll(keepingCapacity: false)
        })
    }

    
}
