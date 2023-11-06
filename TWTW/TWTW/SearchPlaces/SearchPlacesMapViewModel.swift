//
//  SearchPlacesMapViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/13.
//

import Foundation
import UIKit
import RxRelay
import CoreLocation

final class SearchPlacesMapViewModel: NSObject {
    var selectedCoordinateSubject = PublishRelay<CLLocationCoordinate2D>()
    
    ///선택한 좌표로 coordinator로 전달
    func selectLocation(xCoordinate: Double, yCoordinate: Double) {
        selectedCoordinateSubject.accept(CLLocationCoordinate2D(latitude: xCoordinate, longitude: yCoordinate))
    }
}
