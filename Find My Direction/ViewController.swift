//
//  ViewController.swift
//  Find My Direction
//
//  Created by Tadeh Alexani on 2/7/1397 AP.
//  Copyright © 1397 Algorithm. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON
import Alamofire

struct Place {
  let name: String
  let long: Double
  let lat: Double
  let color: UIColor
  
  init(name:String,long:Double,lat:Double, color: UIColor) {
    self.name = name
    self.long = long
    self.lat = lat
    self.color = color
  }
}

class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
  
  var isStart = false
  var isEnd = false
  
  var startLocation: CLLocationCoordinate2D?
  var destinationLocation: CLLocationCoordinate2D?
  
  let locationManager = CLLocationManager()
  
  @IBOutlet weak var mapView: GMSMapView!
  var places = [Place]()
  var placesCoord = [CLLocation]()
  
  var startPlaceColor: UIColor?
  
  let lightBlue = UIColor(hexString: "#72bcd4")
  
  //MARK: - Refresh map
  @IBAction func refreshButtonTapped(_ sender: Any) {
    mapView.clear()
    createMarkersOnMap()
    isStart = false
    isEnd = false
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //Permission for location
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    locationManager.requestAlwaysAuthorization()
    
    //Fill Places array
    places = [
      //Subways
      Place(name: "مترو سبلان", long: 51.46456 , lat: 35.71864, color: UIColor.blue),
      Place(name: "مترو شهید مدنی", long: 51.45336 , lat: 35.70929, color: UIColor.blue),
      Place(name: "مترو امام حسین", long: 51.44585 , lat: 35.70257, color: UIColor.blue),
      Place(name: "مترو صیاد شیرازی", long: 51.45816 , lat: 35.73589, color: lightBlue),
      Place(name: "مترو قدوسی", long: 51.44513 , lat: 35.73132, color: lightBlue),
      Place(name: "مترو سهروردی", long: 51.43597 , lat: 35.73099, color: lightBlue),
      Place(name: "مترو بهشتی", long: 51.42716 , lat: 35.73001, color: lightBlue),
      Place(name: "مترو بهشتی", long: 51.42716 , lat: 35.73001, color: UIColor.red),
      Place(name: "مترو مفتح", long: 51.42780 , lat: 35.72442, color: UIColor.red),
      Place(name: "مترو هفت تیر", long: 51.42607 , lat: 35.71541, color: UIColor.red),
      Place(name: "مترو طالقانی", long: 51.42594 , lat: 35.70719, color: UIColor.red),
      //Busses
      Place(name: "اتوبوس قندی", long: 51.43293, lat: 35.73874, color: UIColor.gray),
      Place(name: "اتوبوس هویزه", long: 51.43264, lat: 35.73437, color: UIColor.gray),
      Place(name: "اتوبوس بهشتی", long: 51.42651, lat: 35.73021, color: UIColor.gray),
      Place(name: "اتوبوس قدوسی", long: 51.44430, lat: 35.73130, color: UIColor.gray),
      Place(name: "اتوبوس سهروردی شمالی", long: 51.44166, lat: 35.73513, color: UIColor.gray),
      Place(name: "اتوبوس پارسا", long: 51.43189, lat: 35.72765, color: UIColor.gray),
      Place(name: "اتوبوس مفتح", long: 51.42770, lat: 35.72860, color: UIColor.gray),
      Place(name: "اتوبوس معلم", long: 51.45122, lat: 35.72790, color: UIColor.gray),
      Place(name: "اتوبوس معلم", long: 51.45122, lat: 35.72790, color: UIColor.gray),
      Place(name: "اتوبوس مطهری", long: 51.44430, lat: 35.72317, color: UIColor.gray),
      Place(name: "اتوبوس مرودشت", long: 51.45084, lat: 35.72361, color: UIColor.gray),
      Place(name: "اتوبوس ملایری پور", long: 51.43344, lat: 35.71982, color: UIColor.gray),
      Place(name: "اتوبوس سهروردی جنوبی", long: 51.43460, lat: 35.72201, color: UIColor.gray),
      Place(name: "اتوبوس ترکمنستان", long: 51.43945, lat: 35.71879, color: UIColor.gray),
      Place(name: "اتوبوس بهار شیراز", long: 51.43581, lat: 35.71664, color: UIColor.gray),
      Place(name: "اتوبوس شریعتی پایین", long: 51.44153, lat: 35.71842, color: UIColor.gray),
      Place(name: "اتوبوس شریعتی بالا", long: 51.44519, lat: 35.73200, color: UIColor.gray),
      Place(name: "اتوبوس ترکمنستان", long: 51.43945, lat: 35.71879, color: UIColor.gray)
    ]
    
    //Fill the Second Array (ViewDidLoad)
    for place in places {
      placesCoord.append(CLLocation(latitude: place.lat, longitude: place.long))
    }
    
    // Create a GMSCameraPosition that tells the map to display the
    let camera = GMSCameraPosition.camera(withLatitude: 35.723407, longitude: 51.443528, zoom: 13.0)
    
    mapView.camera = camera
    mapView.isMyLocationEnabled = true
    mapView.settings.myLocationButton = true
    
    //Create markers on Map
    createMarkersOnMap()
  }
  
  //MARK: - a function to create buss and subway markers on map
  func createMarkersOnMap() {
    for place in places {
      let marker = GMSMarker()
      marker.position = CLLocationCoordinate2D(latitude: place.lat, longitude: place.long)
      marker.title = place.name
      marker.snippet = "Hey, this is \(place.name)"
      marker.icon = GMSMarker.markerImage(with: place.color)
      marker.map = mapView
      marker.appearAnimation = .pop
    }
  }
  
  //MARK: - Location Manager delegates
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Error to get location : \(error)")
  }
  
  // MARK: - GMSMapViewDelegate
  
  func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
    mapView.isMyLocationEnabled = true
  }
  
  func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    mapView.isMyLocationEnabled = true
    
    if (gesture) {
      mapView.selectedMarker = nil
    }
  }
  
  func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
    mapView.isMyLocationEnabled = true
    return false
  }
  
  func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    
    //Destination Marker
    if isStart && !isEnd {
      isEnd = true
      
      let marker = GMSMarker()
      marker.position = coordinate
      marker.icon = GMSMarker.markerImage(with: UIColor.brown)
      marker.map = mapView
      
      let endLocation2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
      
      placesCoord.removeAll()
      
      if startPlaceColor == UIColor.blue || startPlaceColor == lightBlue || startPlaceColor == UIColor.red {
        for place in places {
          if place.color != UIColor.gray {
            placesCoord.append(CLLocation(latitude: place.lat, longitude: place.long))
          }
        }
      } else {
        for place in places {
          if place.color == UIColor.gray {
            placesCoord.append(CLLocation(latitude: place.lat, longitude: place.long))
          }
        }
      }
      
      guard let closest = placesCoord.min(by:
        { $0.distance(from: endLocation2) < $1.distance(from: endLocation2) }) else {
          return
      }
      
      destinationLocation = CLLocationCoordinate2D(latitude: closest.coordinate.latitude, longitude: closest.coordinate.longitude)
      
    }
    
    //Start Marker
    if !isStart {
      isStart = true
      
      let marker = GMSMarker()
      marker.position = coordinate
      marker.icon = GMSMarker.markerImage(with: UIColor.cyan)
      marker.map = mapView
      
      let startLocation2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
      
      guard let closest = placesCoord.min(by:
        { $0.distance(from: startLocation2) < $1.distance(from: startLocation2) }) else {
          return
      }
      
      startPlaceColor = returnColorOFLocation(lat: closest.coordinate.latitude, long: closest.coordinate.longitude)
      
      startLocation = CLLocationCoordinate2D(latitude: closest.coordinate.latitude, longitude: closest.coordinate.longitude)
      
    }
    
  }
  
  func returnColorOFLocation(lat: Double, long: Double) -> UIColor {
    for place in places {
      if place.lat == lat && place.long == long {
        return place.color
      }
    }
    return UIColor.white
  }
  
  func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
    mapView.isMyLocationEnabled = true
    mapView.selectedMarker = nil
    return false
  }
  
  @IBAction func findButtonTapped(_ sender: Any) {
    guard let start = startLocation, let dest = destinationLocation else {
      return
    }
    self.drawPath(startLocation: start, endLocation: dest)
  }
  
  //MARK: - this is function for create direction path, from start location to desination location
  func drawPath(startLocation: CLLocationCoordinate2D, endLocation: CLLocationCoordinate2D)
  {
    let origin = "\(startLocation.latitude),\(startLocation.longitude)"
    let destination = "\(endLocation.latitude),\(endLocation.longitude)"
    
    let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyCKq1LT6NcG6-CYwxiJ7kV6Q3Jp80cpAVQ"
    
    Alamofire.request(url).responseJSON { response in
      print(response.result)
      
      if let json = try? JSON(data: response.data!) {
        let routes = json["routes"].arrayValue
        
        for route in routes
        {
          let routeOverviewPolyline = route["overview_polyline"].dictionary
          let points = routeOverviewPolyline?["points"]?.stringValue
          let path = GMSPath.init(fromEncodedPath: points!)
          let polyline = GMSPolyline.init(path: path)
          polyline.map = self.mapView
        }
      }
    }
  }
}
