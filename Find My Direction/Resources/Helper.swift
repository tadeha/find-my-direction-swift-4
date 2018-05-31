//
//  File.swift
//  Find My Direction
//
//  Created by Tadeh Alexani on 6/1/18.
//  Copyright © 2018 Algorithm. All rights reserved.
//

import UIKit

class Helper {
  
  //MARK: - create a one button alert
  static func createOneButtonAlert(title: String,message: String, actionTitle: String,vc: UIViewController) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    
    alert.addAction(UIAlertAction(title: actionTitle, style: UIAlertActionStyle.default, handler: nil))
    
    vc.present(alert, animated: true, completion: nil)
  }
  
}
