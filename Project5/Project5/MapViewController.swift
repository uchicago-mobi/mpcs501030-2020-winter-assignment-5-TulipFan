//
//  MapViewController.swift
//  Project5
//
//  Created by YAJING FAN on 2/7/20.
//  Copyright © 2020 YAJING FAN. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var FavoriteButton: UIButton!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var BaseView: UIView!
    @IBOutlet weak var placeDescription: UILabel!
    //Keep track of the currently selected annotation
    var selectedAnnotation = Place()
    //Keep track of the current location of the user to alert them with the favorites near him/her
    let locationManager = CLLocationManager()
    
    //Set the region showing on the screen
    override func viewWillAppear(_ animated: Bool) {
        let miles: Double = 2000
        let dictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Data", ofType: "plist")!)
        //Get the coordinates of Chicago from Data.plist
        let ChicagoRegion = dictionary!["region"] as? [Double]
        let zoomLocation = CLLocationCoordinate2DMake(ChicagoRegion![0], ChicagoRegion![1])
        let viewRegion = MKCoordinateRegion(center: zoomLocation, latitudinalMeters: miles, longitudinalMeters: miles)
        mapView.setRegion(viewRegion, animated: true)
        mapView.showsCompass = false
        mapView.pointOfInterestFilter = .excludingAll
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the button to empty star to start
        FavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        FavoriteButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        //Add all annotations and load them
        let placeAnnotation = DataManager.sharedInstance.loadAnnotationFromPlist()
        mapView.addAnnotations(placeAnnotation)
        mapView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Referenced playground from class
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        locationManager.delegate = self
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
          
        //Check permission status
        let authStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
          
        //Handle all different levels of permissions
        switch authStatus {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            return
        case .denied, .restricted:
            presentLocationServicesAlert("Location Services",
                                         message: "Please enable location services for this app in Settings.")
            return
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            fatalError()
        }
    }
    
    func presentLocationServicesAlert(_ title: String, message: String) {
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      let affirmativeAction = UIAlertAction(title: "OK", style: .default) { (alertAction) -> Void in UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
      }
      alert.addAction(affirmativeAction)
      present(alert, animated: true, completion: nil)
    }
    
    @objc func buttonTapped(_ button: UIButton) {
        //If the button is empty star, the annotation is not a favorite currently
        if FavoriteButton.currentImage == UIImage(systemName: "star") {
            DataManager.sharedInstance.saveFavorites(selectedAnnotation)
            FavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }
        //If the button is filled star, the annotation is currenty a favorite
        else if FavoriteButton.currentImage == UIImage(systemName: "star.fill") {
            DataManager.sharedInstance.deleteFavorite(selectedAnnotation)
            FavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        }
    }
    
    //Segue from MapViewController to FavoritesViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? FavoritesViewController {
            destination.delegate = self
        }
    }
}

extension MapViewController: PlacesFavoritesDelegate {
    
    //Show selected favorite in MapViewController
    func favoritePlace(name: String) {
        let placeAnnotation = DataManager.sharedInstance.loadAnnotationFromPlist()
        for item in placeAnnotation {
            if item.name == name {
                selectedAnnotation = item
                FavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            }
        }
        //Center on the selected favorite and update the labels
        let miles: Double = 2000
        let zoomLocation = selectedAnnotation.coordinate
        let viewRegion = MKCoordinateRegion(center: zoomLocation, latitudinalMeters: miles, longitudinalMeters: miles)
        mapView.setRegion(viewRegion, animated: true)
        mapView.showsCompass = false
        mapView.pointOfInterestFilter = .excludingAll
        placeName.text = selectedAnnotation.name
        placeDescription.text = selectedAnnotation.longDescription
    }
}

extension MapViewController: MKMapViewDelegate {
    
    //Referenced from playground in class
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Place {
            let identifier = "Place"
            var view: PlaceMarkerView
            //Deque an annotation view or create a new one
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? PlaceMarkerView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = PlaceMarkerView(annotation: annotation, reuseIdentifier: identifier)
            }
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let Annotation = view.annotation as? Place {
            //Update the labels to show the information of the selected annotation
            placeName.text = Annotation.name
            placeDescription.text = Annotation.longDescription
            selectedAnnotation = Annotation
            if selectedAnnotation.isFavorite {
                //Update the button to filled star if the selected annotation is favorite
                FavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            } else {
                FavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            }
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    //Referenced playground from class
    func locationManager(_ manager: CLLocationManager,
                     didUpdateLocations locations: [CLLocation]) {
        var favoriteList = [String]()
        if let currentLocation = locations.last {
            if let defaults = UserDefaults.standard.array(forKey: "name") as? [String] {
                //For all favorites, check to see if they are close to user's current location ("close" is arbitrary and defined as distance within 3000000
                for favorite in defaults {
                    for annotation in DataManager.sharedInstance.loadAnnotationFromPlist() {
                        if favorite == annotation.name {
                            if currentLocation.distance(from: CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)) < 30000 {
                                favoriteList.append(favorite)
                            }
                        }
                    }
                }
            }
        }
        //favoriteList stores the favorites that are close to the user's current location
        let message = "\(favoriteList)"
        //Alert the user with favorites around him/her when his or her location is updated
        let alert = UIAlertController(title: "Favorites around you", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
