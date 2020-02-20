//
//  Place.swift
//  Project5
//
//  Created by YAJING FAN on 2/7/20.
//  Copyright © 2020 YAJING FAN. All rights reserved.
//

import Foundation
import MapKit

class Place: MKPointAnnotation {
    var name: String? = nil
    var longDescription: String? = nil
    //Check to see if the place is marked as favorite or not to determine if the star should be filled or empty
    var isFavorite: Bool {
        let array: [String] = UserDefaults.standard.array(forKey: "name") as? [String] ?? []
        return array.contains(where: { (currentItem) -> Bool in
            currentItem == self.name
        })
    }
}
