//
//  TestViewController.swift
//  DineMe
//
//  Created by Kyle Wang on 2018-03-08.
//  Copyright © 2018 Kyle Wang. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class MapViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: GMSMapView!
    
    // declare instances
    let locationManager = CLLocationManager()
    
    var marker: GMSMarker?
    var currentLocation: CLLocation?
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    // An array to hold the list of likely places.
    var likelyPlaces: [GMSPlace] = []
    // The currently selected place.
    var selectedPlace: GMSPlace?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // initialize location manager and GMSPPlacesClient
        locationManager.delegate = self
        searchBar.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        
        placesClient = GMSPlacesClient.shared()
        
        searchBar.placeholder = "Search restaurants..."
        mapView.isMyLocationEnabled = true
    }
    
    // Load map view once the location is available from Location Manager
    func loadMapView(location: CLLocation) {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: zoomLevel)
        self.mapView.camera = camera
        
        let initialLocation = CLLocationCoordinate2DMake(latitude, longitude)
        print("initial Location: \(initialLocation)")
        
        marker = GMSMarker(position: initialLocation)
        marker?.title = "Title goes here!"
        marker?.map = mapView
        
        //        if mapView.isHidden {
        //            mapView.isHidden = false
        //            mapView.camera = camera
        //        } else {
        //            mapView.animate(to: camera)
        //        }
    }

}

extension MapViewController: CLLocationManagerDelegate, UISearchBarDelegate, GMSMapViewDelegate {
    
    //*****************************************
    //
    //MARK: - Location Manager Delegate Methods
    //
    //*****************************************
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        // Stop once a location is available
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
        }
        
        loadMapView(location: location)
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
//        marker.position = coordinate
    }
    
//    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
//
//    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    //**************************************
    //
    //MARK: - UI Search Bar Delegate Methods
    //
    //**************************************
    
    //
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}

