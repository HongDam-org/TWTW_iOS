//
//  MainMapViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/11.
//

import UIKit
import NMapsMap
import RxCocoa
import RxSwift
import SnapKit
import CoreLocation //위치정보

///MainMapViewController -지도화면
class MainMapViewController: UIViewController  {
    private let disposeBag = DisposeBag()
    // BottomSheetViewController 생성
    var bottomSheetViewController: BottomSheetViewController!
    //위치 관련 변수
    let locationManager = CLLocationManager()
    var mapView: NMFMapView!
    
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        setupLocationManager()
        
        
    }
    // MARK: -  viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        setupBottomSheet()
        
    }
    
    //setupBottomSheet()
    private func setupBottomSheet(){
        // let bottomSheetViewController = BottomSheetViewController()
        bottomSheetViewController = BottomSheetViewController()
        addChild(bottomSheetViewController)
        view.addSubview(bottomSheetViewController.view)
        bottomSheetViewController.didMove(toParent: self)
        
        bottomSheetViewController.view.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(bottomSheetViewController.midHeight)
        }
        
    }
    
    // setupMapView()
    private func setupMapView() {
        mapView = NMFMapView(frame: view.frame)
        mapView.positionMode = .normal
        
        view.addSubview(mapView)
    }
    
    // setupLocationManager() 설정
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
}



extension MainMapViewController :CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else { return }
        
        // 지도 카메라를 사용자의 현재 위치로 이동
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: location.latitude, lng: location.longitude))
        mapView.moveCamera(cameraUpdate)
        
        // 위치 업데이트 중단
        locationManager.stopUpdatingLocation()
    }
}

