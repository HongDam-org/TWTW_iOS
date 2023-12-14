//
//  SearchPlacesMapCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/13.
//

import CoreLocation
import Foundation
import UIKit

protocol SearchPlacesMapCoordinatorProtocol: Coordinator {
    /// 서치 완료후 :  cLLocation전달 & pop VC
    func finishSearchPlaces(coordinate: CLLocationCoordinate2D, placeName: String, roadAddressName: String)

}
