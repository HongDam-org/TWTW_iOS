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


public let DEFAULT_POSITION = MTMapPointGeo(latitude: 37.576568, longitude: 127.029148) //초기 지도의 기본 위치 : 서울

///MainMapViewController - 지도화면
final class MainMapViewController: UIViewController  {
    let locationDelegate = LocationManagerDelegate()
    
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
    
    
    private lazy var mapView: MTMapView = {
        let mapView = MTMapView()
        mapView.delegate = self
        mapView.baseMapType = .standard
        mapView.setMapCenter(MTMapPoint(geoCoord: DEFAULT_POSITION), zoomLevel: 1, animated: true)
        mapView.showCurrentLocationMarker = true
        mapView.currentLocationTrackingMode = .onWithoutHeading
        
        return mapView
    }()
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        locationDelegate.checkAuthorizationStatus()
        setupMapViewUI()
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
    
    private func addSubViews() {
        view.addSubview(mapView)
        configureConstraints()
    }
    
    private func configureConstraints(){
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    /// MARK: Add BottomSheet UI
    private func addBottomSheetSubViews() {
        view.addSubview(bottomSheetViewController.view)
        bottomSheetViewController.didMove(toParent: self)
        configureBottomSheetConstraints()
    }
    
    /// MARK: Configure Constraints UI
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
