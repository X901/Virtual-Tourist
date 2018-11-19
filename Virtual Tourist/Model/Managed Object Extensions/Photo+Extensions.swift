//
//  Notebook+Extensions.swift
//  Mooskine
//
//  Created by X901 on 12/11/2018.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
import CoreData

extension Photo {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
