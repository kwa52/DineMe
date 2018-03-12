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
import GooglePlacePicker

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    
    // declare instances
    let locationManager = CLLocationManager()
    // Declare GMSMarker instance at the class level.
    let infoMarker = GMSMarker()
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    
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
        mapView.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        
        // access the class used for searching and getting details about places
        placesClient = GMSPlacesClient.shared()

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
        marker?.snippet = "Hello World"
        marker?.title = "Title goes here!"
        marker?.map = mapView
    }

    @IBAction func autocompleteUIButtonPressed(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
}







extension MapViewController: CLLocationManagerDelegate, UISearchBarDelegate, GMSMapViewDelegate, GMSAutocompleteResultsViewControllerDelegate, GMSAutocompleteViewControllerDelegate {
    
    
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
    
    // Move the marker to position where user tapped
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        marker?.position = coordinate
        marker?.map = mapView
    }
    
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
    
    //************************************
    //
    //MAR: - GMS Map View Delegate Methods
    //
    //************************************
    
    // Attach an info window to the POI using the GMSMarker.
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String,
                 name: String, location: CLLocationCoordinate2D) {
        infoMarker.snippet = placeID
        infoMarker.position = location
        infoMarker.title = name
        infoMarker.opacity = 0;
        infoMarker.infoWindowAnchor.y = 1
        infoMarker.map = mapView
        mapView.selectedMarker = infoMarker
    }
    
    //*****************************************************
    //
    //MARK: - Autocomplete View Controller Delegate Methods
    //
    //*****************************************************
    
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(String(describing: place.formattedAddress))")
        print("Place attributions: \(String(describing: place.attributions))")
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    //************************************************************
    //
    //MARK: - Autocomplete Result View Controller Delegate Methods
    //
    //************************************************************
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(String(describing: place.formattedAddress))")
        print("Place attributions: \(String(describing: place.attributions))")
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        print("didRequestAutocompletePridiciton called")
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        print("didUpdateAutocompletePridiciton called")
    }
    
    //**************************************
    //
    //MARK: - UI Search Bar Delegate Methods
    //
    //**************************************
    
    //
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            
            DispatchQueue.main.async {
                // dismiss the keyboard and cursor on the search bar
                searchBar.resignFirstResponder()
            }
        }
    }
}

