//
//  CLLocationManagerMock.swift
//  TWTW
//
//  Created by 정호진 on 10/24/23.
//

import Foundation
import CoreLocation


protocol CLLocationManagerProtocol: CLLocationManager {
    var mockLocation: CLLocation? {get set}
}


final class CLLocationManagerMock: CLLocationManager, CLLocationManagerProtocol {
    var mockLocation: CLLocation?
    
}
