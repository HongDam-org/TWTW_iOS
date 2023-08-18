//
//  LocationManagerDelegate.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/18.
//
import CoreLocation

class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()

    override init() {
        super.init()
        
        locationManager.delegate = self
      
        // 다른 위치 관리자 설정
    }
    /// 위치 권한 확인을 위한 메소드 checkAuthorizationStatus()
    func checkAuthorizationStatus() {
        let clLocationManager = CLLocationManager()
        let status = clLocationManager.authorizationStatus
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("위치 서비스 권한이 허용")
        
            // 위치 관련 작업 수행
        case .denied, .restricted:
            print("위치 서비스 권한이 거부")
          
        case .notDetermined:
            print("위치 서비스 권한이 아직 결정되지 않음")
           
            locationManager.requestWhenInUseAuthorization()
        default:
            fatalError("알 수 없는 권한 상태")
        }
    }

    // 권한 상태 변경 시 호출되는 델리게이트 메서드
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorizationStatus()
    }
}
