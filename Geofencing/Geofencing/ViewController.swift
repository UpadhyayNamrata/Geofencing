//
//  ViewController.swift
//  Geofencing
//
//  Created by Namrata BizBrolly on 09/10/24.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {

    var existingAnnotaion : MKPointAnnotation?
    var currentLocationStr = "Current location"
    var currentLocation: CLLocation?
    var isRegionSet = false
    @IBOutlet weak var mkMapView: MKMapView!

    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        manager.requestWhenInUseAuthorization()
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        return manager
    }()

    let coordinates = CLLocationCoordinate2D(latitude: 28.624118, longitude: 77.381879)
    let regionRadious = 100.0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add re-center button
               let recenterButton = UIButton(frame: CGRect(x: 20, y: view.bounds.height - 80, width: 100, height: 40))
               recenterButton.setTitle("Recenter", for: .normal)
               recenterButton.backgroundColor = UIColor.systemBlue
               recenterButton.layer.cornerRadius = 8
               recenterButton.addTarget(self, action: #selector(recenterMap), for: .touchUpInside)
               view.addSubview(recenterButton)
        // Do any additional setup after loading the view.

        locationManager.startUpdatingLocation()
        mkMapView.delegate = self
        mkMapView.showsUserLocation = true
        mkMapView.isScrollEnabled = true
        mkMapView.userTrackingMode = .follow
        startMonitoringGeofenceRegion()
        let existingAnnotaion = MKPointAnnotation()
        existingAnnotaion.subtitle = "D - 23, Sector - 63, Noida"
        existingAnnotaion.title = "Bizbrolly"
        existingAnnotaion.coordinate = CLLocationCoordinate2D(latitude: 28.624118, longitude: 77.381879)
        mkMapView.addAnnotation(existingAnnotaion)
    }


    func creategeofencing() -> CLCircularRegion{
        // Your coordinates go here (lat, lon)
        let geofenceRegion = CLCircularRegion(center: coordinates,
                                              radius: regionRadious,
                                              identifier: "UniqueIdentifier")
        geofenceRegion.notifyOnEntry = true
        geofenceRegion.notifyOnExit = true
        return geofenceRegion
    }

    func startMonitoringGeofenceRegion(){
        let geofenceRegion = creategeofencing()
        let geofenceOverlay = MKCircle(center: coordinates, radius: 100)
        mkMapView.addOverlay(geofenceOverlay)
        locationManager.startMonitoring(for: geofenceRegion)
    }

    // Recenter map to current location
       @objc func recenterMap() {
           guard let location = currentLocation else { return }
           let region = MKCoordinateRegion(
               center: location.coordinate,
               latitudinalMeters: 1000,
               longitudinalMeters: 1000
           )
           mkMapView.setRegion(region, animated: false)
       }
}

extension ViewController: CLLocationManagerDelegate, MKMapViewDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            print("When user did not yet determined")
        case .restricted:
            print("Restricted by parental control")
        case .denied:
            print("When user select option Dont't Allow")
        case .authorizedAlways:
            print("Geofencing feature has user permission")
            locationManager.requestAlwaysAuthorization()
        case .authorizedWhenInUse:
            // Request Always Allow permission
            // after we obtain When In Use permission
            locationManager.requestAlwaysAuthorization()
        default:
            print("default")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            if let extistingannotation = self.existingAnnotaion{
                mkMapView.removeAnnotation(extistingannotation)
            }

            currentLocation = location
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse{
            locationManager.startUpdatingLocation()
        }else{
            locationManager.stopUpdatingHeading()
        }
    }

    //MARK:- Intance Methods

//    func setUsersClosestLocation(mLattitude: CLLocationDegrees, mLongitude: CLLocationDegrees) -> String {
//        let geoCoder = CLGeocoder()
//        let location = CLLocation(latitude: mLattitude, longitude: mLongitude)
//
//        geoCoder.reverseGeocodeLocation(location) {
//            (placemarks, error) -> Void in
//
//            if let mPlacemark = placemarks{
//                if let dict = mPlacemark[0].addressDictionary as? [String: Any]{
//                    if let Name = dict["Name"] as? String{
//                        if let City = dict["City"] as? String{
//                            self.currentLocationStr = Name + ", " + City
//                        }
//                    }
//                }
//            }
//        }
//        return currentLocationStr
//    }


    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("User Entered")
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("User Exited")
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle{
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.strokeColor = .blue
            circleRenderer.fillColor = .blue.withAlphaComponent(0.3)
            circleRenderer.lineWidth =  1.0
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
