//
//  LocationManager.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 25/6/2024.
//
import Foundation
import MapKit

final class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var region = MKCoordinateRegion()
    @Published var location : (lat: Double, long: Double)=(K.Location.lat,K.Location.long)
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.setup()
    }

    private func setup() {
      switch locationManager.authorizationStatus {
      //If we are authorized then we request location just once,
      // to center the map
      case .authorizedWhenInUse:
        locationManager.requestLocation()
      //If we don´t, we request authorization
      case .notDetermined:
          locationManager.startUpdatingLocation()
          locationManager.requestWhenInUseAuthorization()
      default:
        break
      }
    }
    
    func distDiff(_ lat: Double,_ long : Double) -> Double{
        return abs(lat - self.location.lat) + abs( long - self.location.long)
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard .authorizedWhenInUse == manager.authorizationStatus else { return }
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Something went wrong: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        locations.last.map {
            region = MKCoordinateRegion(
                center: $0.coordinate,
                span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            location.lat = $0.coordinate.latitude
            location.long = $0.coordinate.longitude
        }
    }
    
    
}
