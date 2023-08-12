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
final class MainMapViewController: UIViewController  {
    
    /// MARK: 지도 아랫부분 화면
    private lazy var bottomSheetViewController: BottomSheetViewController = {
        let view = BottomSheetViewController()
        
        return view
    }()
    
    /// MARK: 네이버 지도
    private lazy var mapView: NMFMapView = {
        var view = NMFMapView()
        view.positionMode = .normal
        return view
    }()
    
    private let disposeBag = DisposeBag()
    private let viewModel = MainMapViewModel()
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        setupLocationManager()
        addSubViews()
        
    }
    // MARK: -  View Did Appear
    override func viewDidAppear(_ animated: Bool) {
        addSubViews()
    }
    
    
    
    // MARK: - Fuctions
    
    /// MARK: Add UI
    private func addSubViews() {
        view.addSubview(bottomSheetViewController.view)
        bottomSheetViewController.didMove(toParent: self)
        bottomSheetViewController.delegate = self // 델리게이트 설정
        
        configureConstraints()
    }
        
    /// MARK:
    private func configureConstraints() {
        
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
        let locationManager = viewModel.locationManagerRelay.value
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
        viewModel.locationManagerRelay.value.stopUpdatingLocation()
    }
}
// BottomSheetDelegate 프로토콜
extension MainMapViewController: BottomSheetDelegate {
    func didUpdateBottomSheetHeight(_ height: CGFloat) {
        bottomSheetViewController.view.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
