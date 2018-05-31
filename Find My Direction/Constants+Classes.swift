//
//  Constants+Classes.swift
//  Find My Direction
//
//  Created by Tadeh Alexani on 6/1/18.
//  Copyright © 2018 Algorithm. All rights reserved.
//

import UIKit

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
