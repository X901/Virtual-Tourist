//
//  FlikerModel.swift
//  Virtual Tourist
//
//  Created by X901 on 23/11/2018.
//  Copyright © 2018 X901. All rights reserved.
//

import Foundation

struct FlikerResbonse : Codable {
    let photos : Photos
    let stat : String
    
}

struct Photos : Codable {
    let perpage : Int
    let photo : [PhotoParse]
    
}

struct PhotoParse : Codable {
    let id : String
    let url_m : String
    
}


