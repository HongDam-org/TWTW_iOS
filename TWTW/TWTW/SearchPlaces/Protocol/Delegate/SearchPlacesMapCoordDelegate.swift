//
//  SearchPlacesMapCoordDelegate.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/16.
//

import CoreLocation
import Foundation

/// SearchPlaces 위치전달로 맵 카메라 이동
protocol SearchPlacesMapCoordDelegate: AnyObject {
    func didSelectPlace(searchPlace: SearchPlace)
}
