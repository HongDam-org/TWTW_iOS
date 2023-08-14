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
    
    /// 지도 화면 터치 감지 Relay
    ///  true: UI 제거하기, false: UI 표시
    var checkTouchEventRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    
    // MARK: - Logic
    
    func setupLocationManager() {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func checkingTouchEvents() {
        let check = checkTouchEventRelay.value
        checkTouchEventRelay.accept(!check)
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
