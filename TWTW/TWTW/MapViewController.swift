//
//  MapViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/17.
//

import Foundation
import UIKit

class MapViewController : UIViewController, MTMapViewDelegate{
    
    var mapView: MTMapView?

       override func viewDidLoad() {
           super.viewDidLoad()
           mapView = MTMapView(frame: self.view.bounds)
          
           if let mapView = mapView {
               mapView.delegate = self
               mapView.baseMapType = .standard
               self.view.addSubview(mapView)
           }
       }
   }
