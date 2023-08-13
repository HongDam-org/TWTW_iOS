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

final class MainMapViewModel: NSObject {
    
    /// 위치 정보 저장하는 Relay
    let locationManagerRelay: BehaviorRelay<CLLocationCoordinate2D> = BehaviorRelay<CLLocationCoordinate2D>(value: kCLLocationCoordinate2DInvalid)
    func setupLocationManager() {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}
extension MainMapViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else { return }
        
        // 위치 업데이트 시 currentLocationRelay를 업데이트합니다.
        locationManagerRelay.accept(location)
        
        // 위치 업데이트 중단
        manager.stopUpdatingLocation()
    }
}
