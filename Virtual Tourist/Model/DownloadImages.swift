//
//  DownloadImages.swift
//  Virtual Tourist
//
//  Created by X901 on 26/11/2018.
//  Copyright © 2018 X901. All rights reserved.
//

import Foundation
import UIKit

private func downloadImage(using cell: PhotoAlbumCollectionViewCell, photo: Photo) {
    if let imageData = photo.imageData {
        DispatchQueue.main.async {
            cell.imageFlikr.image = UIImage(data: imageData)
        }
    } else {
        if let imageUrl = URL(string: photo.imageUrl!) {
            do {
                let imageData = try Data(contentsOf: imageUrl)
                let image = UIImage(data: imageData)
                DispatchQueue.main.async {
                    cell.imageFlikr.image = image
                }
                photo.imageData = imageData
            } catch{
                print("failed to download image from URL")
            }
        }
    }
}
