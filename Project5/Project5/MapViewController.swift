//
//  MapViewController.swift
//  Project5
//
//  Created by YAJING FAN on 2/7/20.
//  Copyright © 2020 YAJING FAN. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var FavoriteButton: UIButton!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var BaseView: UIView!
    @IBOutlet weak var placeDescription: UILabel!
    var selectedAnnotation = Place()
    
    override func viewWillAppear(_ animated: Bool) {
        let miles: Double = 20 * 1600
        let dictionary = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Data", ofType: "plist")!)
        let ChicagoRegion = dictionary!["region"] as? [Double]
        let zoomLocation = CLLocationCoordinate2DMake(ChicagoRegion![0], ChicagoRegion![1])
        let viewRegion = MKCoordinateRegion(center: zoomLocation, latitudinalMeters: miles, longitudinalMeters: miles)
        mapView.setRegion(viewRegion, animated: true)
        mapView.showsCompass = false
        mapView.pointOfInterestFilter = .excludingAll
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        FavoriteButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        let placeAnnotation = DataManager.sharedInstance.loadAnnotationFromPlist()
        mapView.addAnnotations(placeAnnotation)
        mapView.delegate = self
    }
    
    @objc func buttonTapped(_ button: UIButton) {
        if FavoriteButton.currentImage == UIImage(systemName: "star") {
            DataManager.sharedInstance.saveFavorites(selectedAnnotation)
            FavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }
        else if FavoriteButton.currentImage == UIImage(systemName: "star.fill") {
            DataManager.sharedInstance.deleteFavorite(selectedAnnotation)
            FavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? FavoritesViewController {
            destination.delegate = self
        }
    }
}

extension MapViewController: PlacesFavoritesDelegate {
    
    func favoritePlace(name: String) {
        let placeAnnotation = DataManager.sharedInstance.loadAnnotationFromPlist()
        for item in placeAnnotation {
            if item.name == name {
                selectedAnnotation = item
                FavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            }
        }
        let miles: Double = 20 * 160
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
            placeName.text = Annotation.name
            placeDescription.text = Annotation.longDescription
            selectedAnnotation = Annotation
            if selectedAnnotation.isFavorite {
                FavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            } else {
                FavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            }
        }
    }
}
