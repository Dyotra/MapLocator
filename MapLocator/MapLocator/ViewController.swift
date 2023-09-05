//
//  ViewController.swift
//  MapLocator
//
//  Created by Bekpayev Dias on 05.09.2023.
//

import UIKit
import MapKit
import SnapKit
import CoreLocation

class ViewController: UIViewController {
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    var locationStory: [CLLocationCoordinate2D] = []
    var totalDistance: CLLocationDistance = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        mapView.showsUserLocation = true
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        mapView.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 20
        locationManager.startUpdatingLocation()
    }
}
 
 
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let locationC = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        locationStory.append(locationC)
        if locationStory.count >= 2 {
            let previousLocation = CLLocation(latitude: locationStory[locationStory.count - 2].latitude, longitude: locationStory[locationStory.count - 2].longitude)
            let currentLocation = CLLocation(latitude: locationC.latitude, longitude: locationC.longitude)
            let distance = currentLocation.distance(from: previousLocation)
            totalDistance += distance
        }
        mapView.zoomTo(locationC)
        drawLocations()
        updateDistanceLabel()
    }
    func drawLocations() {
        let line = MKPolygon(coordinates: locationStory, count: locationStory.count)
        mapView.addOverlay(line)
    }
    func updateDistanceLabel() {
        mapView.removeAnnotations(mapView.annotations)
        
        let distanceAnnotation = MKPointAnnotation()
        distanceAnnotation.title = "Total Distance"
        distanceAnnotation.subtitle = String(format: "%.2f meters", totalDistance)
        distanceAnnotation.coordinate = locationStory.last ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        
        mapView.addAnnotation(distanceAnnotation)
    }
}
extension MKMapView {
    func zoomTo(_ location: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
        let region = MKCoordinateRegion(center: location, span: span)
        self.setRegion(region, animated: true)
    }
}
 
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyLineRenderer = MKPolylineRenderer(overlay: overlay)
                polyLineRenderer.strokeColor = .systemRed
                polyLineRenderer.lineWidth = 10
                return polyLineRenderer
    }
}

