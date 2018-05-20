//
//  ViewController.swift
//  Find My Direction
//
//  Created by Tadeh Alexani on 2/7/1397 AP.
//  Copyright © 1397 Algorithm. All rights reserved.
//

import UIKit
import GoogleMaps

class Node {
  var visited = false
  var connections: [Connection] = []
}

class Connection {
  public let to: Node
  public let weight: Int
  
  public init(to node: Node, weight: Int) {
    assert(weight >= 0, "weight has to be equal or greater than zero")
    self.to = node
    self.weight = weight
  }
}

class Path {
  public let cumulativeWeight: Int
  public let node: Node
  public let previousPath: Path?
  
  init(to node: Node, via connection: Connection? = nil, previousPath path: Path? = nil) {
    if
      let previousPath = path,
      let viaConnection = connection {
      self.cumulativeWeight = viaConnection.weight + previousPath.cumulativeWeight
    } else {
      self.cumulativeWeight = 0
    }
    
    self.node = node
    self.previousPath = path
  }
}

extension Path {
  var array: [Node] {
    var array: [Node] = [self.node]
    
    var iterativePath = self
    while let path = iterativePath.previousPath {
      array.append(path.node)
      
      iterativePath = path
    }
    
    return array
  }
}

class Place: Node {
  let name: String
  let long: Double
  let lat: Double
  let color: UIColor
  
  init(name:String,long:Double,lat:Double, color: UIColor) {
    self.name = name
    self.long = long
    self.lat = lat
    self.color = color
    super.init()
  }
}

let lightBlue = UIColor(hexString: "#72bcd4")

class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
  
  var isStart = false
  var isEnd = false
  
  var startLocation: CLLocationCoordinate2D?
  var destinationLocation: CLLocationCoordinate2D?
  var estimatedTime = 0
  var startPlace: Place?
  var destPlace: Place?
  var startPlaceColor: UIColor?
  
  var places = [Place]()
  var placesCoord = [CLLocation]()
  var routes = [CLLocationCoordinate2D]()
  
  let locationManager = CLLocationManager()
  
  @IBOutlet weak var mapView: GMSMapView!
  
  //MARK: - Refresh app
  @IBAction func refreshButtonTapped(_ sender: Any) {
    //reload application data (renew root view )
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: "Root_View")
    UIApplication.shared.keyWindow?.rootViewController = controller
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //Permission for location
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    locationManager.requestAlwaysAuthorization()
    
    let sabalanSub = Place(name: "مترو سبلان", long: 51.46456 , lat: 35.71864, color: UIColor.blue)
    let madaniSub = Place(name: "مترو شهید مدنی", long: 51.45336 , lat: 35.70929, color: UIColor.blue)
    let imamHosseinSub = Place(name: "مترو امام حسین", long: 51.44585 , lat: 35.70257, color: UIColor.blue)
    let sayadSub = Place(name: "مترو صیاد شیرازی", long: 51.45816 , lat: 35.73589, color: lightBlue)
    let ghodoosiSub = Place(name: "مترو قدوسی", long: 51.44513 , lat: 35.73132, color: lightBlue)
    let sohrevardiSub = Place(name: "مترو سهروردی", long: 51.43597 , lat: 35.73099, color: lightBlue)
    let beheshtiSub = Place(name: "مترو بهشتی", long: 51.42716 , lat: 35.73001, color: lightBlue)
    let mofatehSub = Place(name: "مترو مفتح", long: 51.42780 , lat: 35.72442, color: UIColor.red)
    let hafteTirSub = Place(name: "مترو هفت تیر", long: 51.42607 , lat: 35.71541, color: UIColor.red)
    let taleghaniSub = Place(name: "مترو طالقانی", long: 51.42594 , lat: 35.70719, color: UIColor.red)
    let ghandiBus = Place(name: "اتوبوس قندی", long: 51.43293, lat: 35.73874, color: UIColor.gray)
    let hoveyzeBus = Place(name: "اتوبوس هویزه", long: 51.43264, lat: 35.73437, color: UIColor.gray)
    let beheshtiBus = Place(name: "اتوبوس بهشتی", long: 51.42651, lat: 35.73021, color: UIColor.gray)
    let ghodoosiBus = Place(name: "اتوبوس قدوسی", long: 51.44430, lat: 35.73130, color: UIColor.gray)
    let northSohrevardiBus = Place(name: "اتوبوس سهروردی شمالی", long: 51.44166, lat: 35.73513, color: UIColor.gray)
    let parsaBus = Place(name: "اتوبوس پارسا", long: 51.43189, lat: 35.72765, color: UIColor.gray)
    let mofatehBus = Place(name: "اتوبوس مفتح", long: 51.42770, lat: 35.72860, color: UIColor.gray)
    let moalemBus = Place(name: "اتوبوس معلم", long: 51.45122, lat: 35.72790, color: UIColor.gray)
    let motahariBus = Place(name: "اتوبوس مطهری", long: 51.44430, lat: 35.72317, color: UIColor.gray)
    let marvdashtBus = Place(name: "اتوبوس مرودشت", long: 51.45084, lat: 35.72361, color: UIColor.gray)
    let malayeriPoorBus = Place(name: "اتوبوس ملایری پور", long: 51.43344, lat: 35.71982, color: UIColor.gray)
    let southSohrevardiBus = Place(name: "اتوبوس سهروردی جنوبی", long: 51.43460, lat: 35.72201, color: UIColor.gray)
    let torkamanestanBus = Place(name: "اتوبوس ترکمنستان", long: 51.43945, lat: 35.71879, color: UIColor.gray)
    let bahareShirazBus = Place(name: "اتوبوس بهار شیراز", long: 51.43581, lat: 35.71664, color: UIColor.gray)
    let downShariatyBus = Place(name: "اتوبوس شریعتی پایین", long: 51.44153, lat: 35.71842, color: UIColor.gray)
    let upShariatiBus = Place(name: "اتوبوس شریعتی بالا", long: 51.44519, lat: 35.73200, color: UIColor.gray)
    
    //Line 2 - Sub
    sabalanSub.connections.append(Connection(to: madaniSub, weight: 5))
    madaniSub.connections.append(Connection(to: imamHosseinSub, weight: 5))
    madaniSub.connections.append(Connection(to: sabalanSub, weight: 5))
    imamHosseinSub.connections.append(Connection(to: madaniSub, weight: 5))
    
    //Line 3 - Sub
    sayadSub.connections.append(Connection(to: ghodoosiSub, weight: 5))
    ghodoosiSub.connections.append(Connection(to: sayadSub, weight: 5))
    ghodoosiSub.connections.append(Connection(to: sohrevardiSub, weight: 5))
    sohrevardiSub.connections.append(Connection(to: ghodoosiSub, weight: 5))
    sohrevardiSub.connections.append(Connection(to: beheshtiSub, weight: 5))
    beheshtiSub.connections.append(Connection(to: sohrevardiSub, weight: 5))
    beheshtiSub.connections.append(Connection(to: mofatehSub, weight: 5))
    
    //Line 1 - Sub
    mofatehSub.connections.append(Connection(to: beheshtiSub, weight: 5))
    mofatehSub.connections.append(Connection(to: hafteTirSub, weight: 5))
    hafteTirSub.connections.append(Connection(to: mofatehSub, weight: 5))
    hafteTirSub.connections.append(Connection(to: taleghaniSub, weight: 5))
    taleghaniSub.connections.append(Connection(to: hafteTirSub, weight: 5))
    
    // Busses
    moalemBus.connections.append(Connection(to: marvdashtBus, weight: 3))
    moalemBus.connections.append(Connection(to: ghodoosiBus, weight: 3))
    ghodoosiBus.connections.append(Connection(to: moalemBus, weight: 3))
    ghodoosiBus.connections.append(Connection(to: upShariatiBus, weight: 3))
    marvdashtBus.connections.append(Connection(to: moalemBus, weight: 3))
    marvdashtBus.connections.append(Connection(to: motahariBus, weight: 3))
    motahariBus.connections.append(Connection(to: marvdashtBus, weight: 3))
    motahariBus.connections.append(Connection(to: downShariatyBus, weight: 3))
    upShariatiBus.connections.append(Connection(to: northSohrevardiBus, weight: 3))
    upShariatiBus.connections.append(Connection(to: ghodoosiBus, weight: 3))
    northSohrevardiBus.connections.append(Connection(to: upShariatiBus, weight: 3))
    northSohrevardiBus.connections.append(Connection(to: hoveyzeBus, weight: 3))
    ghandiBus.connections.append(Connection(to: hoveyzeBus, weight: 3))
    hoveyzeBus.connections.append(Connection(to: ghandiBus, weight: 3))
    hoveyzeBus.connections.append(Connection(to: parsaBus, weight: 3))
    parsaBus.connections.append(Connection(to: hoveyzeBus, weight: 3))
    parsaBus.connections.append(Connection(to: beheshtiBus, weight: 3))
    beheshtiBus.connections.append(Connection(to: mofatehBus, weight: 3))
    beheshtiBus.connections.append(Connection(to: parsaBus, weight: 3))
    mofatehBus.connections.append(Connection(to: beheshtiBus, weight: 3))
    mofatehBus.connections.append(Connection(to: southSohrevardiBus, weight: 3))
    southSohrevardiBus.connections.append(Connection(to: mofatehBus, weight: 3))
    southSohrevardiBus.connections.append(Connection(to: malayeriPoorBus, weight: 3))
    malayeriPoorBus.connections.append(Connection(to: southSohrevardiBus, weight: 3))
    malayeriPoorBus.connections.append(Connection(to: bahareShirazBus, weight: 3))
    bahareShirazBus.connections.append(Connection(to: malayeriPoorBus, weight: 3))
    bahareShirazBus.connections.append(Connection(to: downShariatyBus, weight: 3))
    downShariatyBus.connections.append(Connection(to: torkamanestanBus, weight: 3))
    downShariatyBus.connections.append(Connection(to: bahareShirazBus, weight: 3))
    torkamanestanBus.connections.append(Connection(to: downShariatyBus, weight: 3))
    torkamanestanBus.connections.append(Connection(to: motahariBus, weight: 3))
    
    //Fill Places array
    places = [
      //Subways
      sabalanSub,
      madaniSub,
      imamHosseinSub,
      sayadSub,
      ghodoosiSub,
      sohrevardiSub,
      beheshtiSub,
      mofatehSub,
      hafteTirSub,
      taleghaniSub,
      //Busses
      ghandiBus,
      hoveyzeBus,
      beheshtiBus,
      ghodoosiBus,
      northSohrevardiBus,
      parsaBus,
      mofatehBus,
      moalemBus,
      motahariBus,
      marvdashtBus,
      malayeriPoorBus,
      southSohrevardiBus,
      torkamanestanBus,
      bahareShirazBus,
      downShariatyBus,
      upShariatiBus
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
  
  //MARK: - create a one button alert
  func createOneButtonAlert(title: String,message: String, actionTitle: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    
    alert.addAction(UIAlertAction(title: actionTitle, style: UIAlertActionStyle.default, handler: nil))
    
    self.present(alert, animated: true, completion: nil)
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
      marker.icon = UIImage(named: "dest")
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
      
      destPlace = returnPlaceOfLocation(lat: closest.coordinate.latitude, long: closest.coordinate.longitude)
      
    }
    
    //Start Marker
    if !isStart {
      isStart = true
      
      let marker = GMSMarker()
      marker.position = coordinate
      marker.icon = UIImage(named: "start")
      marker.map = mapView
      
      let startLocation2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
      
      guard let closest = placesCoord.min(by:
        { $0.distance(from: startLocation2) < $1.distance(from: startLocation2) }) else {
          return
      }
      
      startPlaceColor = returnColorOFLocation(lat: closest.coordinate.latitude, long: closest.coordinate.longitude)
      
      startPlace = returnPlaceOfLocation(lat: closest.coordinate.latitude, long: closest.coordinate.longitude)
      
    }
  }
  
  //MARK: - Dijkstra’s Algorithm Shortest Path Function
  func shortestPath(source: Node, destination: Node) -> Path? {
    var frontier: [Path] = [] {
      didSet { frontier.sort { return $0.cumulativeWeight < $1.cumulativeWeight } }
    }
    
    frontier.append(Path(to: source))
    
    while !frontier.isEmpty {
      let cheapestPathInFrontier = frontier.removeFirst()
      guard !cheapestPathInFrontier.node.visited else { continue }
      
      if cheapestPathInFrontier.node === destination {
        estimatedTime = cheapestPathInFrontier.cumulativeWeight
        return cheapestPathInFrontier
      }
      
      cheapestPathInFrontier.node.visited = true
      
      for connection in cheapestPathInFrontier.node.connections where !connection.to.visited {
        
        frontier.append(Path(to: connection.to, via: connection, previousPath: cheapestPathInFrontier))
      }
    }
    return nil
  }
  
  
  func findClosest(to location: CLLocationCoordinate2D) -> CLLocation {
    let loc = CLLocation(latitude: location.latitude, longitude: location.longitude)
    let closest = placesCoord.min(by: { $0.distance(from: loc) < $1.distance(from: loc) })
    return closest!
  }
  
  func returnColorOFLocation(lat: Double, long: Double) -> UIColor {
    for place in places {
      if place.lat == lat && place.long == long {
        return place.color
      }
    }
    return UIColor.white
  }
  
  func returnPlaceOfLocation(lat: Double, long: Double) -> Place {
    for place in places {
      if place.lat == lat && place.long == long {
        return place
      }
    }
    return Place(name: "nil", long: 1, lat: 1, color: UIColor.white)
  }
  
  func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
    mapView.isMyLocationEnabled = true
    mapView.selectedMarker = nil
    return false
  }
  
  @IBAction func findButtonTapped(_ sender: Any) {
    guard let start = startPlace, let dest = destPlace else {
      return
    }
    
    let sourceNode = start
    let destinationNode = dest
    
    let path = shortestPath(source: sourceNode, destination: destinationNode)
    
    if let lats: [Double] = path?.array.reversed().flatMap({ $0 as? Place}).map({$0.lat}) {
      if let longs: [Double] = path?.array.reversed().flatMap({ $0 as? Place}).map({$0.long}) {
        var i = 0
        while i < lats.count {
          routes.append(CLLocationCoordinate2D(latitude: lats[i], longitude: longs[i]))
          i = i+1
        }
      }
    }
    
    if let succession: [String] = path?.array.reversed().flatMap({ $0 as? Place}).map({$0.name}) {
      drawPath()
      var routesString = ""
      for route in succession {
        routesString += route
        routesString += "\n"
      }
      createOneButtonAlert(title: "مسیر پیدا شد", message: "زمان تخمینی : \(String(describing: estimatedTime)) دقیقه \n مسیر پیشنهادی: \n  \(routesString)", actionTitle: "ممنون")
      
    } else {
      createOneButtonAlert(title: "مسیر پیدا نشد", message: "مسیری بین \(sourceNode.name) و \(destinationNode.name) پیدا نشد!", actionTitle: "اکی")
    }
    
  }
  
  //MARK: - this is function for create direction path, from start location to desination location
  func drawPath()
  {
    let path = GMSMutablePath()
    for route in routes {
      path.add(route)
    }
    let polyline = GMSPolyline(path: path)
    polyline.map = mapView
  }
  
}
