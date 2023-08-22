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

///MainMapViewController - 지도화면
final class MainMapViewController: UIViewController  {
    /// MARK: 버튼역할의 서치바UI
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "장소, 주소 검색"
        searchBar.showsCancelButton = false
        return searchBar
    }()
    
    /// MARK: 지도 아랫부분 화면
    private lazy var bottomSheetViewController: BottomSheetViewController = {
        let view = BottomSheetViewController()
        view.viewHeight.accept(self.view.frame.height)
        view.delegate = self
        return view
    }()
    
    /// MARK: 지도
    private lazy var mapView: MTMapView = {
        let mapView = MTMapView()
        mapView.delegate = self
        mapView.baseMapType = .standard
        mapView.setMapCenter(MTMapPoint(geoCoord: Map.DEFAULT_POSITION), zoomLevel: 1, animated: true)
        mapView.showCurrentLocationMarker = true
        DispatchQueue.global().async {
            mapView.currentLocationTrackingMode = .onWithoutHeading
        }
        return mapView
    }()
    
    private let disposeBag = DisposeBag()
    private let viewModel = MainMapViewModel()
    private var tapGesture: UITapGestureRecognizer?
    private let locationManager = CLLocationManager()
    private var initBottomheight = 0.0
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        initBottomheight = view.bounds.height*(0.2)
        setupMapViewUI()
        configureLocationManager()
        bind()
        
    }
    
    // MARK: -  View Did Appear
    override func viewDidAppear(_ animated: Bool) {
        addSubViews_BottomSheet()
        setupSearchBar()
        
    }
    
    // MARK: - Fuctions
    
    /// MARK: configureLocationManager
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
  
    /// MARK: set up MapView UI
    private func setupMapViewUI() {
        addSubViews()
        addTapGesture_Map()
       
    }
    
    /// MARK: Add  UI
    private func addSubViews() {
        view.addSubview(mapView)
        configureConstraints()
        
    }
    /// MARK: Add  UI - SearchBar
    private func addSubViews_SearchBar(){
        view.addSubview(searchBar)
        configureConstraints_SearchBar()
        //addTapGesture_SearchBar()
        
    }
    /// MARK: Add  UI - BottomSheet
    private func addSubViews_BottomSheet() {
        view.addSubview(bottomSheetViewController.view)
        bottomSheetViewController.didMove(toParent: self)
        configureConstraints_BottomSheet()
    }
    ///MARK: Setup - SearchBar
    private func setupSearchBar() {
        addSubViews_SearchBar()
        searchBar.delegate = self // 서치바의 delegate 설정
    }
    
    /// MARK: Configure Constraints UI
    private func configureConstraints(){
        ///mapView
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
      
    }
    /// MARK: Configure   Constraints UI - SearchBar
    private func configureConstraints_SearchBar() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.trailing.equalToSuperview().inset(10)
          
        }
        
    }
    /// MARK: Configure  Constraints UI - BottomSheet
    private func configureConstraints_BottomSheet() {
        bottomSheetViewController.view.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(initBottomheight)
        }
    }
    ///MARK: Add  Gesture - Map
    private func addTapGesture_Map(){
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture ?? UITapGestureRecognizer())
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
                    self?.bottomSheetViewController.view.alpha = 1
                    
                    self?.bottomSheetViewController.view.isHidden = false
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

// MARK: - MTMapViewDelegate
extension MainMapViewController: MTMapViewDelegate{
    
    /// Custom: 현 위치 트래킹 함수
    func mapView(_ mapView: MTMapView!, updateCurrentLocation location: MTMapPoint!, withAccuracy accuracy: MTMapLocationAccuracy) {
        let currentLocation = location?.mapPointGeo()
        if let latitude = currentLocation?.latitude, let longitude = currentLocation?.longitude{
            print("MTMapView updateCurrentLocation (\(latitude),\(longitude)) accuracy (\(accuracy))")
        }
    }
    
    /// 단말기 머리 방향 업데이트
    func mapView(_ mapView: MTMapView?, updateDeviceHeading headingAngle: MTMapRotationAngle) {
        print("MTMapView updateDeviceHeading (\(headingAngle)) degrees")
    }
}

// MARK: - CLLocationManagerDelegate
extension MainMapViewController: CLLocationManagerDelegate {
    
    /// 위치 권한 확인 변화 됐을 때 실행
    internal func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
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
// MARK: - SearchBar Delegate
extension MainMapViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        let searchPlacesMapVC = SearchPlacesMapViewController() // 다음 화면의 뷰 컨트롤러 생성
       // searchPlacesMapVC.modalPresentationStyle = .fullScreen
        present(searchPlacesMapVC, animated: true)
        return false // 검색 동작을 막기 위해 false 반환
    }
}
