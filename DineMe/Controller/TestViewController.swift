//
//  TestViewController.swift
//  DineMe
//
//  Created by Kyle Wang on 2018-03-08.
//  Copyright © 2018 Kyle Wang. All rights reserved.
//

import UIKit
import GoogleMaps

class TestViewController: UIViewController {

    @IBOutlet weak var testMapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let camera = GMSCameraPosition.camera(withLatitude: 52.520736, longitude: 13.409423, zoom: 12)
        self.testMapView.camera = camera
        
        let initialLocation = CLLocationCoordinate2DMake(52.520736, 13.409423)
        let marker = GMSMarker(position: initialLocation)
        marker.title = "Berlin"
        marker.map = testMapView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func loadView() {
//        // Create a GMSCameraPosition that tells the map to display the
//        // coordinate -33.86,151.20 at zoom level 6.
//        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
//        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
//        view = mapView
//
//        // Creates a marker in the center of the map.
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
//        marker.title = "Sydney"
//        marker.snippet = "Australia"
//        marker.map = self.testMapView
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//extension TestViewController: GMSMapViewDelegate{
//
//}

