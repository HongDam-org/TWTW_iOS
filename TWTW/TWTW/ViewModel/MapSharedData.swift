//
//  MapSharedData.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/05.
//

import Foundation
import CoreLocation

final class MapSharedData {
    static let shared = MapSharedData()

    // 선택한 좌표를 저장하는 변수
    var selectedCoordinate: CLLocationCoordinate2D?

    private init() {}
}
