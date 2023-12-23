//
//  FindRoadViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/18.
//

import CoreLocation
import KakaoMapsSDK
import RxSwift
import UIKit

final class FindRoadViewController: KakaoMapViewController {
    private var destinationCoordinate = CLLocationCoordinate2D(latitude: 37.403419311975, longitude: 126.72003443712)
    private var locationManager = CLLocationManager()
    
    private var currentLocation: CLLocationCoordinate2D?
    
    private lazy var infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    /// 내 위치
    private lazy var myLocationView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    private lazy var myLocationLabel: UILabel = {
        let label = UILabel()
        label.text = "출발지: 실제 위치"
        return label
    }()
    
    /// 목적지 위치
    private lazy var destinationView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    private lazy var destinationLabel: UILabel = {
        let label = UILabel()
        label.text = "목적지: 인천광역시 남동구 논현동 633-8"
        return label
    }()
    
    private lazy var carRouteButton: UIButton = {
        let button = UIButton()
        button.setTitle("자동차 경로", for: .normal)
        button.backgroundColor = .blue
        return button
    }()
    
    private lazy var walkRouteButton: UIButton = {
        let button = UIButton()
        button.setTitle("인도", for: .normal)
        button.backgroundColor = .green
        return button
    }()
 
    private let viewModel: FindRoadViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Init
    init(viewModel: FindRoadViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationManager()
        bind()
        carRouteButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                print("차 길 보기")
                self?.drawCarRoute()
                
            })
            .disposed(by: disposeBag)
        walkRouteButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                print("인도 길 보기")
                self?.drawWalkRoute()
            })
            .disposed(by: disposeBag)
      
    }
    /// binding
    private func bind() {
        myLocationLabel.isUserInteractionEnabled = true

        let myLocationLabelTap = myLocationLabel.rx.tapGesture()
            .when(.recognized)
            .map { _ in }
            .asObservable()

        let input = FindRoadViewModel.Input(myLocationTap: myLocationLabelTap)

        viewModel.bind(input: input)
    }
    
    override func addViews() {
        let defaultPosition: MapPoint = MapPoint(longitude: 126.733529, latitude: 37.3401906)
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition)
        
        if mapController?.addView(mapviewInfo) == Result.OK {
            print("OK")
           
        }
        createLabelLayer()
        createPoiStyle()
        createPois()
        showBasicGUIs()
    }
    

    // MARK: - Setup UI
    
    private func setupUI() {
        view.addSubview(infoView)
        infoView.addSubview(myLocationLabel)
        infoView.addSubview(destinationLabel)
        infoView.addSubview(carRouteButton)
        infoView.addSubview(walkRouteButton)
        
        infoView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(0)
            make.height.equalTo(150)
        }
        
        myLocationLabel.snp.makeConstraints { make in
            make.top.equalTo(infoView.snp.top).offset(20)
            make.leading.trailing.equalTo(infoView).inset(10)
        }
        
        destinationLabel.snp.makeConstraints { make in
            make.top.equalTo(myLocationLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(infoView).inset(10)
        }
        
        carRouteButton.snp.makeConstraints { make in
            make.top.equalTo(destinationLabel.snp.bottom).offset(20)
            make.leading.equalTo(infoView.snp.leading).offset(10)
            make.height.equalTo(30)
        }
        
        walkRouteButton.snp.makeConstraints { make in
            make.top.equalTo(destinationLabel.snp.bottom).offset(20)
            make.trailing.equalTo(infoView.snp.trailing).offset(-10)
            make.height.equalTo(30)
            make.leading.equalTo(carRouteButton.snp.trailing).offset(10)
            make.width.equalTo(carRouteButton.snp.width)
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
}

// 마커 // 37.3401906, 126.733529
extension FindRoadViewController {

    func createLabelLayer() {
        let view = mapController?.getView("mapview") as? KakaoMap
        let manager = view?.getLabelManager()
        let layerOption = LabelLayerOptions(layerID: "PoiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 10001)
        let _ = manager?.addLabelLayer(option: layerOption)
    }
    
    func createPoiStyle() {
        let view = mapController?.getView("mapview") as? KakaoMap
        let manager = view?.getLabelManager()
        
        let startPinIcon = PoiIconStyle(symbol: UIImage(named: "pin_green.png"), anchorPoint: CGPoint(x: 0.5, y: 0.5))
        let startText = PoiTextLineStyle(textStyle: TextStyle(fontSize: 25, fontColor: UIColor.white, strokeThickness: 0))
        let startTextStyle = PoiTextStyle(textLineStyles: [startText])
        startTextStyle.textLayouts = [PoiTextLayout.center]
        let startPoiStyle = PoiStyle(styleID: "customStyle1", styles: [
            PerLevelPoiStyle(iconStyle: startPinIcon, textStyle: startTextStyle, level: 0)
        ])
        
        
        let endPinIcon = PoiIconStyle(symbol: UIImage(named: "pin_red.png"), anchorPoint: CGPoint(x: 0.5, y: 0.5))
        
        let endText = PoiTextLineStyle(textStyle: TextStyle(fontSize: 25, fontColor: UIColor.white, strokeThickness: 0))
        let endTextStyle = PoiTextStyle(textLineStyles: [endText])
        endTextStyle.textLayouts = [PoiTextLayout.center]
        let endPoiStyle = PoiStyle(styleID: "customStyle2", styles: [
            PerLevelPoiStyle(iconStyle: endPinIcon, textStyle: endTextStyle, level: 0)
        ])
        
        manager?.addPoiStyle(startPoiStyle)
        manager?.addPoiStyle(endPoiStyle)
    }
    
    func createPois() {
        let view = mapController?.getView("mapview") as? KakaoMap
        let manager = view?.getLabelManager()
        let trackingManager = view?.getTrackingManager()
        
        /// 출발
        let positionLayer = manager?.getLabelLayer(layerID: "PoiLayer")
        let poiOption = PoiOptions(styleID: "customStyle1", poiID: "poi1")
        poiOption.rank = 1
        poiOption.transformType = .decal
        poiOption.addText(PoiText(text: "출발", styleIndex: 0))
        
        /// 도착
        let endPositionLayer = manager?.getLabelLayer(layerID: "PoiLayer")
        let endPoiOption = PoiOptions(styleID: "customStyle2", poiID: "poi2")
        endPoiOption.rank = 1
        endPoiOption.transformType = .decal
        endPoiOption.addText(PoiText(text: "도착", styleIndex: 0))
        
        if let startPoi = positionLayer?.addPoi(option: poiOption, at: MapPoint(longitude: 126.73570807, latitude: 37.3977149815)) {
            startPoi.show()
            trackingManager?.startTrackingPoi(startPoi)
        }
        if let endPoi = endPositionLayer?.addPoi(option: endPoiOption, at: MapPoint(longitude: 126.79570807, latitude: 37.3977149815)) {
            endPoi.show()
            trackingManager?.startTrackingPoi(endPoi)
        }
    }
    
}

extension FindRoadViewController {
    
    func showBasicGUIs() {
        let view = mapController?.getView("mapview") as? KakaoMap
        guard let view = view else { return }
        view.setCompassPosition(origin: GuiAlignment(vAlign: .bottom, hAlign: .left), position: CGPoint(x: 10.0, y: 10.0))
        view.showCompass()
      
        view.setScaleBarPosition(origin: GuiAlignment(vAlign: .bottom, hAlign: .right), position: CGPoint(x: 10.0, y: 10.0))
        view.showScaleBar()
        view.setScaleBarFadeInOutOption(FadeInOutOptions(fadeInTime: 2, fadeOutTime: 2, retentionTime: 3))    }
}
extension FindRoadViewController {
    
    // 경로 레이어 제거 함수
    private func removeRouteLayer(layerID: String) {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = mapView.getRouteManager()
        manager.removeRouteLayer(layerID: layerID)
    }
    /// 차 경로 그리기
    private func drawCarRoute() {
        removeRouteLayer(layerID: "CarRouteLayer")
        removeRouteLayer(layerID: "WalkRouteLayer")
        
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = mapView.getRouteManager()
        
        let layer = manager.addRouteLayer(layerID: "CarRouteLayer", zOrder: 0)

        createRouteStyleSet()
    
        guard let currentLocation = currentLocation else {
            print("현재 위치 정보가 없습니다.")
            return
        }
        let destination = CLLocationCoordinate2D(latitude: 37.3977149815, longitude: 126.79570807)
        let startMapPoint = MapPoint(longitude: currentLocation.longitude, latitude: currentLocation.latitude)
        let endMapPoint = MapPoint(longitude: destination.longitude, latitude: destination.latitude)
        let segment = RouteSegment(points: [startMapPoint, endMapPoint], styleIndex: 0)
  
        let options = RouteOptions(routeID: "CarRoute", styleID: "routeStyleSet1", zOrder: 0)
        options.segments = [segment]
        let route = layer?.addRoute(option: options)
        route?.show()
    }
    
    /// MARK: 보도 경로 그리기
    private func drawWalkRoute() {
        removeRouteLayer(layerID: "CarRouteLayer")
        removeRouteLayer(layerID: "WalkRouteLayer")
        
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = mapView.getRouteManager()
        
        // 1 RouteLayer 생성
        let layer = manager.addRouteLayer(layerID: "WalkRouteLayer", zOrder: 0)
        
        // 2 RouteStyleSet 생성
        createRouteStyleSet()
        
        // 3 RouteSegment 생성
        guard let currentLocation = currentLocation else {
            print("현재 위치 정보가 없습니다.")
            return
        }
        let destination = CLLocationCoordinate2D(latitude: 37.3977149815, longitude: 126.79570807)
        let startMapPoint = MapPoint(longitude: currentLocation.longitude, latitude: currentLocation.latitude)
        let endMapPoint = MapPoint(longitude: destination.longitude, latitude: destination.latitude)
        let segment = RouteSegment(points: [startMapPoint, endMapPoint], styleIndex: 0)
        
        // 4 Route 추가
        let options = RouteOptions(routeID: "walkRoute", styleID: "routeStyleSet1", zOrder: 0)
        options.segments = [segment]
        let route = layer?.addRoute(option: options)
        route?.show()
    }
    
    /// 선택한 좌표로 카메라 옮기기
    private func moveCameraToCoordinate(_ coordinate: CLLocationCoordinate2D, _ output: MainMapViewModel.Output) {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }
        mapView.animateCamera(cameraUpdate: CameraUpdate.make(target: MapPoint(longitude: coordinate.longitude,
                                                                               latitude: coordinate.latitude),
                                                              zoomLevel: 15,
                                                              rotation: 1.7,
                                                              tilt: 0.0,
                                                              mapView: mapView),
                              options: CameraAnimationOptions(autoElevation: true,
                                                              consecutive: true,
                                                              durationInMillis: 2000),
                              callback: { })
    }
    
    // MARK: - Route Functions
    /// 길찾기 표시
    private func createRouteStyleSet() {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }
        // 라우트 매니저 초기화
        let manager = mapView.getRouteManager()
        manager.removeRouteLayer(layerID: "RouteLayer")
        // 라우트 레이어 추가
        _ = manager.addRouteLayer(layerID: "RouteLayer", zOrder: 0)
        // 라인 패턴 이미지 배열
        let patternImages = [UIImage(named: "route_pattern_arrow.png"),
                             UIImage(named: "route_pattern_walk.png"),
                             UIImage(named: "route_pattern_long_dot.png")]
        
        // pattern
        let styleSet = RouteStyleSet(styleID: "routeStyleSet1")
        guard let image1 = patternImages[0], let image2 = patternImages[1] else {return}
        styleSet.addPattern(RoutePattern(pattern: image1, distance: 60, symbol: nil, pinStart: false, pinEnd: false))
        styleSet.addPattern(RoutePattern(pattern: image2, distance: 6, symbol: nil, pinStart: false, pinEnd: false))
        
        let routeStyle = RouteStyle(styles: [
            PerLevelRouteStyle(width: 15,
                               color: UIColor.mapLineColor ?? .clear,
                               strokeWidth: 4,
                               strokeColor: UIColor.mapStrokeColor ?? .clear,
                               level: 0,
                               patternIndex: 0)
        ])
        
        styleSet.addStyle(routeStyle)
        manager.addRouteStyleSet(styleSet)
    }
}
// MARK: - CLLocationManagerDelegate
extension FindRoadViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let newCoordinate = location.coordinate
        
        if currentLocation == nil {
            currentLocation = newCoordinate
        }
        
        myLocationLabel.text = "내 위치: \(newCoordinate.latitude), \(newCoordinate.longitude)"
        moveCameraToCoordinate(newCoordinate)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            // 위치 서비스 권한 처리
            break
        }
    }
    
    
    private func moveCameraToCoordinate(_ coordinate: CLLocationCoordinate2D) {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }
        mapView.animateCamera(cameraUpdate: CameraUpdate.make(target: MapPoint(longitude: coordinate.longitude,
                                                                               latitude: coordinate.latitude),
                                                              zoomLevel: 10,
                                                              rotation: 1.7,
                                                              tilt: 0.0,
                                                              mapView: mapView), options: .init())
    }
}
