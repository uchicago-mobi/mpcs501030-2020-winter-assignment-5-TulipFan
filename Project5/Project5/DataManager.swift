//
//  DataManager.swift
//  Project5
//
//  Created by YAJING FAN on 2/7/20.
//  Copyright © 2020 YAJING FAN. All rights reserved.
//

import Foundation
import MapKit

public class DataManager {
    
    public static let sharedInstance = DataManager()
    fileprivate init() {}
    
    //User var places to store all the available locations as Place() instance
    func loadAnnotationFromPlist() -> [Place] {
        let dictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Data", ofType: "plist")!)
        let placeDict = dictionary!["places"] as? [[String: Any]]
        var places = [Place()]
        for item in placeDict! {
            let annotation = Place()
            annotation.name = item["name"] as? String
            annotation.longDescription = item["description"] as? String
            annotation.title = annotation.name
            annotation.coordinate = CLLocationCoordinate2DMake((item["lat"] as? Double)!, (item["long"] as? Double)!)
            places.append(annotation)
        }
        return places
    }
    
    func saveFavorites(_ placeAnnotation: Place) {
        let userDefaults = UserDefaults.standard.array(forKey: "name") as? [String] ?? []
        //If nothing is in UserDefaults, create a list of names for key "name"
        if userDefaults.count == 0 {
            let newDefaults = UserDefaults.standard
            newDefaults.set([placeAnnotation.name], forKey: "name")
        }
        //If there is a list of favorites in UserDefaults, add additional favorite to the array
        else {
            var defaults = UserDefaults.standard.array(forKey: "name") as? [String]
            defaults?.append(placeAnnotation.name!)
            UserDefaults.standard.set(defaults, forKey: "name")
        }
    }
    
    func deleteFavorite(_ placeAnnotation: Place) {
        for (idx, item) in UserDefaults.standard.array(forKey: "name")!.enumerated() {
            if item as? String == placeAnnotation.name {
                var defaults = UserDefaults.standard.array(forKey: "name") as? [String]
                defaults?.remove(at: idx)
                UserDefaults.standard.set(defaults, forKey: "name")
                break
            }
        }
    }
}
