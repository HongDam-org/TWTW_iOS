//
//  MainMapViewModel.swift
//  TWTW
//
//  Created by 정호진 on 2023/08/12.
//

import Foundation
import RxSwift
import RxRelay
import CoreLocation

final class MainMapViewModel {
    
    /// 위치 정보 저장하는 Relay
    let locationManagerRelay: BehaviorRelay<CLLocationManager> = BehaviorRelay<CLLocationManager>(value: CLLocationManager())
    
}
