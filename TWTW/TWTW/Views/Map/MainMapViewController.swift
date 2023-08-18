//
//  MainMapViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/11.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import CoreLocation

public let DEFAULT_POSITION = MTMapPointGeo(latitude: 37.576568, longitude: 127.029148) //초기 지도의 기본 위치 : 서울

///MainMapViewController - 지도화면
final class MainMapViewController: UIViewController  {
    
    /// MARK: 지도 아랫부분 화면
    private lazy var bottomSheetViewController: BottomSheetViewController = {
        let viewModel = BottomSheetViewModel(viewHeight: self.view.frame.height)// 필요한 초기값으로 설정
        let view = BottomSheetViewController(viewModel: viewModel)
        view.delegate = self
        return view
    }()
    
    private let disposeBag = DisposeBag()
    private let viewModel = MainMapViewModel()
    private var tapGesture: UITapGestureRecognizer?
    private let locationManager = CLLocationManager()

    
    private lazy var mapView: MTMapView = {
        let mapView = MTMapView()
        mapView.delegate = self
        mapView.baseMapType = .standard
        mapView.setMapCenter(MTMapPoint(geoCoord: DEFAULT_POSITION), zoomLevel: 1, animated: true)
        mapView.showCurrentLocationMarker = true
        DispatchQueue.global().async {
            mapView.currentLocationTrackingMode = .onWithoutHeading
        }
        
        return mapView
    }()
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapViewUI()
        configureLocationManager()
        bind()
    }
    // MARK: -  View Did Appear
    override func viewDidAppear(_ animated: Bool) {
        addBottomSheetSubViews()
    }
    
    // MARK: - Fuctions
    
    private func setupMapViewUI() {
        addSubViews()
    }
    /// MARK: configureLocationManager
    private func configureLocationManager() {
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        }
    /// MARK: Add  UI
    private func addSubViews() {
        view.addSubview(mapView)
        configureConstraints()
    }
    /// MARK: Add BottomSheet UI
    private func addBottomSheetSubViews() {
        view.addSubview(bottomSheetViewController.view)
        bottomSheetViewController.didMove(toParent: self)
        configureBottomSheetConstraints()
    }
    
    /// MARK: Configure Constraints UI
    private func configureConstraints(){
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    /// MARK: Configure  BottomSheet Constraints UI
    private func configureBottomSheetConstraints() {
        bottomSheetViewController.view.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(bottomSheetViewController.viewModel.minHeight)
        }
    }
    /// MARK: viewModel binding
    private func bind(){
        
        viewModel.checkTouchEventRelay
            .bind { [weak self] check in
                if check {  // 화면 터치시 주변 UI 숨기기
                    UIView.animate(withDuration: 0.5, animations: {
                        self?.bottomSheetViewController.view.alpha = 0
                    }) { (completed) in
                        if completed {
                            self?.bottomSheetViewController.view.isHidden = true
                        }
                    }
                }
                else{
                    UIView.animate(withDuration: 0.5, animations: {
                        self?.bottomSheetViewController.view.alpha = 1
                    }) { (completed) in
                        if completed {
                            self?.bottomSheetViewController.view.isHidden = false
                        }
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    /// MARK: 터치 이벤트 실행
    @objc
    private func handleTap(_ gesture: UITapGestureRecognizer) {
        viewModel.checkingTouchEvents()
    }
}

// MARK: - extension

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
// MTMapViewDelegate 프로토콜
extension MainMapViewController: MTMapViewDelegate{
    // Custom: 현 위치 트래킹 함수
    func mapView(_ mapView: MTMapView!, updateCurrentLocation location: MTMapPoint!, withAccuracy accuracy: MTMapLocationAccuracy) {
        let currentLocation = location?.mapPointGeo()
        if let latitude = currentLocation?.latitude, let longitude = currentLocation?.longitude{
            print("MTMapView updateCurrentLocation (\(latitude),\(longitude)) accuracy (\(accuracy))")
        }
    }
    func mapView(_ mapView: MTMapView?, updateDeviceHeading headingAngle: MTMapRotationAngle) {
        print("MTMapView updateDeviceHeading (\(headingAngle)) degrees")
    }
}
// CLLocationManagerDelegate
extension MainMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            checkAuthorizationStatus()
        }
    /// 위치 권한 확인을 위한 메소드 checkAuthorizationStatus()
        private func checkAuthorizationStatus() {
            let status = locationManager.authorizationStatus
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
    }

