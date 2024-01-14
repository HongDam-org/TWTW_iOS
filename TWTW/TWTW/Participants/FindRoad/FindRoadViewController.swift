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

enum Mode: Int {
    case hidden = 0,
         show,
         tracking
}
final class FindRoadViewController: KakaoMapViewController {
    var timer: Timer?
    var currentPositionPoi: Poi?
    var currentDirectionArrowPoi: Poi?
    var currentDirectionPoi: Poi?
    var currentHeading: Double
    var currentPosition: GeoCoordinate
    var mode: Mode
    var moveOnce: Bool
    var locationManager: CLLocationManager
    var locationServiceAuthorized: CLAuthorizationStatus
    
    
    private let startCoordinate = CLLocationCoordinate2D(latitude: 37.3977149815, longitude: 126.73570807)
    private let destinationCoordinate = CLLocationCoordinate2D(latitude: 37.3977149815, longitude: 126.79570807)
    
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
    
    private lazy var pedRouteButton: UIButton = {
        let button = UIButton()
        button.setTitle("인도", for: .normal)
        button.backgroundColor = .green
        return button
    }()
    
    private let viewModel: FindRoadViewModel
    private let disposeBag = DisposeBag()
    private var output: FindRoadViewModel.Output?

    // MARK: - Init
    init(viewModel: FindRoadViewModel) {
        self.viewModel = viewModel
        locationServiceAuthorized = CLAuthorizationStatus.notDetermined
        locationManager = CLLocationManager()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        currentHeading = 0
        currentPosition = GeoCoordinate()
        mode = .hidden
        moveOnce = false
        super.init()
        locationManager.delegate = self
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
    }
    /// binding
    private func bind() {
        let myLocationLabelTap = myLocationLabel.rx.tapGesture()
            .when(.recognized)
            .map { _ in }
            .asObservable()
        let carRouteButtonTap = carRouteButton.rx.tap.asObservable()
        let pedRouteButtonTap = pedRouteButton.rx.tap.asObservable()

        let input = FindRoadViewModel.Input(myLocationTap: myLocationLabelTap, carRouteButtonTap: carRouteButtonTap, pedRouteButtonTap: pedRouteButtonTap)
        
        let output = viewModel.bind(input: input)
        self.output = output
        
        myLocationLabel.isUserInteractionEnabled = true
        viewModel.bind(input: input)
 
           // carRouteButtonTap 이벤트에 대한 구독
        carRouteButtonTap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let pathList = output.destinationCarPathRelay.value
                // 경로 리스트가 비어있지 않은지 확인
                if !pathList.isEmpty && !pathList.contains(where: { $0.isEmpty }) {
                    self.drawCarRoute(pathList: pathList)
                }
            })
            .disposed(by: disposeBag)
        
        pedRouteButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                print("인도 길 보기")
                let features = output.destinationPedPathRelay.value
                self?.drawPedRoute(features: features)
            })
            .disposed(by: disposeBag)

    }
    
    override func addViews() {
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: Map.DEFAULTPOSITION)
        
        if mapController?.addView(mapviewInfo) == Result.OK {
            print("OK")
            createLabelLayer()
            createPoiStyle()
            createPois()
            showBasicGUIs()
            
            createSpriteGUI()
            createWaveShape()
            
        }
    }
    
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.addSubview(infoView)
        infoView.addSubview(myLocationLabel)
        infoView.addSubview(destinationLabel)
        infoView.addSubview(carRouteButton)
        infoView.addSubview(pedRouteButton)
        
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
        
        pedRouteButton.snp.makeConstraints { make in
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
        locationManager.startUpdatingHeading()
        
    }
    
}
extension FindRoadViewController {
    
    func createLabelLayer() {
        let view = mapController?.getView("mapview") as? KakaoMap
        let manager = view?.getLabelManager()
        let layerOption = LabelLayerOptions(layerID: "PoiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 10001)
        let _ = manager?.addLabelLayer(option: layerOption)
        //
        let positionLayerOption = LabelLayerOptions(layerID: "myPositionPoiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 0)
        let _ = manager?.addLabelLayer(option: positionLayerOption)
        let directionLayerOption = LabelLayerOptions(layerID: "myDirectionPoiLayer", competitionType: .none, competitionUnit: .symbolFirst, orderType: .rank, zOrder: 10)
        let _ = manager?.addLabelLayer(option: directionLayerOption)
 
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
        
        //
        let myLocationMarker = PoiIconStyle(symbol: UIImage(named: "map_ico_marker.png"))
        let myLocationPerLevelStyle1 = PerLevelPoiStyle(iconStyle: myLocationMarker, level: 0)
        let  myLocationPoiStyle1 = PoiStyle(styleID: "myPositionPoiStyle", styles: [myLocationPerLevelStyle1])
        manager?.addPoiStyle(myLocationPoiStyle1)
        
        let direction = PoiIconStyle(symbol: UIImage(named: "map_ico_marker_direction.png"), anchorPoint: CGPoint(x: 0.5, y: 0.995))
        let myLocationPerLevelStyle2 = PerLevelPoiStyle(iconStyle: direction, level: 0)
        let myLocationPoiStyle2 = PoiStyle(styleID: "myDirectionArrowPoiStyle", styles: [myLocationPerLevelStyle2])
        manager?.addPoiStyle(myLocationPoiStyle2)
        
        let area = PoiIconStyle(symbol: UIImage(named: "map_ico_direction_area.png"), anchorPoint: CGPoint(x: 0.5, y: 0.995))
        let myLocationPerLevelStyle3 = PerLevelPoiStyle(iconStyle: area, level: 0)
        let myLocationPoiStyle3 = PoiStyle(styleID: "myDirectionPoiStyle", styles: [myLocationPerLevelStyle3])
        manager?.addPoiStyle(myLocationPoiStyle3)
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
        
        let myPositionLayer = manager?.getLabelLayer(layerID: "myPositionPoiLayer")
        let myDirectionLayer = manager?.getLabelLayer(layerID: "myDirectionPoiLayer")
        
        // 현위치마커의 몸통에 해당하는 POI
        let myLocationPoiOption = PoiOptions(styleID: "myPositionPoiStyle", poiID: "myPositionPOI")
        myLocationPoiOption.rank = 1
        myLocationPoiOption.transformType = .decal    // 화면이 기울여졌을 때, 지도를 따라 기울어져서 그려지도록 한다.
        let myLocationPosition: MapPoint = MapPoint(longitude: 127.108678, latitude: 37.402001)
        
        currentPositionPoi = myPositionLayer?.addPoi(option: myLocationPoiOption, at: myLocationPosition)
        
        // 현위치마커의 방향표시 화살표에 해당하는 POI
        let myLocationPoiOption2 = PoiOptions(styleID: "myDirectionArrowPoiStyle", poiID: "myDirectionArrowPOI")
        myLocationPoiOption2.rank = 3
        myLocationPoiOption2.transformType = .absoluteRotationDecal
        
        currentDirectionArrowPoi = myPositionLayer?.addPoi(option: myLocationPoiOption2, at: myLocationPosition)
        
        // 현위치마커의 부채꼴모양 방향표시에 해당하는 POI
        let myLocationPoiOption3 = PoiOptions(styleID: "myDirectionPoiStyle", poiID: "myDirectionPOI")
        myLocationPoiOption3.rank = 2
        myLocationPoiOption3.transformType = .decal
        
        currentDirectionPoi = myDirectionLayer?.addPoi(option: myLocationPoiOption3, at: myLocationPosition)
        
        currentPositionPoi?.shareTransformWithPoi(currentDirectionArrowPoi!)  //몸통이 방향표시와 위치 및 방향을 공유하도록 지정한다. 몸통 POI의 위치가 변경되면 방향표시 POI의 위치도 변경된다. 반대는 변경안됨.
        currentDirectionArrowPoi?.shareTransformWithPoi(currentDirectionPoi!) //방향표시가 부채꼴모양과 위치 및 방향을 공유하도록 지정한다.
    }
    // 현위치 마커에 원형 물결효과를 주기 위해 원형 Polygon을 추가한다.
    func createWaveShape() {
        let view = mapController?.getView("mapview") as? KakaoMap
        let manager = view?.getShapeManager()
        let layer = manager?.addShapeLayer(layerID: "shapeLayer", zOrder: 10001, passType: .route)
        
        let shapeStyle = PolygonStyle(styles: [
            PerLevelPolygonStyle(color: UIColor(red: 0.3, green: 0.7, blue: 0.9, alpha: 1.0), level: 0)
        ])
        let shapeStyleSet = PolygonStyleSet(styleSetID: "shapeLevelStyle")
        shapeStyleSet.addStyle(shapeStyle)
        manager?.addPolygonStyleSet(shapeStyleSet)
        
        let options = PolygonShapeOptions(shapeID: "waveShape", styleID: "shapeLevelStyle", zOrder: 1)
        let points = Primitives.getCirclePoints(radius: 10.0, numPoints: 90, cw: true)
        let polygon = Polygon(exteriorRing: points, hole: nil, styleIndex: 0)
        
        options.polygons.append(polygon)
        options.basePosition = MapPoint(longitude: 0, latitude: 0)
        
        let shape = layer?.addPolygonShape(options)
        currentDirectionPoi?.shareTransformWithShape(shape!)   // 현위치마커 몸통이 Polygon이 위치 및 방향을 공유하도록 지정한다.
    }
    
    func createAndStartWaveAnimation() {
        let mapView: KakaoMap? = mapController?.getView("mapview") as? KakaoMap
        let manager = mapView?.getShapeManager()
        let layer = manager?.getShapeLayer(layerID: "shapeLayer")
        let shape = layer?.getPolygonShape(shapeID: "waveShape")
        let waveEffect = WaveAnimationEffect(datas: [
            WaveAnimationData(startAlpha: 0.8, endAlpha: 0.0, startRadius: 10.0, endRadius: 100.0, level: 0)
        ])
        waveEffect.hideAtStop = true
        waveEffect.interpolation = AnimationInterpolation(duration: 1000, method: .cubicOut)
        waveEffect.playCount = 5
        
        let animator = manager?.addShapeAnimator(animatorID: "circleWave", effect: waveEffect)
        animator?.addPolygonShape(shape!)
        animator?.start()
    }
    // 현위치마커 버튼 GUI
    func createSpriteGUI() {
        let mapView = mapController?.getView("mapview") as? KakaoMap
        let spriteLayer = mapView?.getGuiManager().spriteGuiLayer
        let spriteGui = SpriteGui("ButtonGui")
        
        spriteGui.arrangement = .horizontal
        spriteGui.bgColor = UIColor.clear
        spriteGui.splitLineColor = UIColor.white
        spriteGui.origin = GuiAlignment(vAlign: .bottom, hAlign: .right)
        
        let button = GuiButton("CPB")
        button.image = UIImage(named: "track_location_btn.png")
        
        spriteGui.addChild(button)
        
        spriteLayer?.addSpriteGui(spriteGui)
        spriteGui.delegate = self
        spriteGui.show()
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
    private func drawCarRoute(pathList: [[Double]]) {
        guard !pathList.isEmpty else {
            print("경로 데이터가 없습니다.")
            return
        }
        removeRouteLayer(layerID: "CarRouteLayer")
        removeRouteLayer(layerID: "WalkRouteLayer")

        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = mapView.getRouteManager()
        
        /// RouteLayer 생성
        let layer = manager.addRouteLayer(layerID: "CarRouteLayer", zOrder: 0)
        
        // RouteStyleSet 생성
        createRouteStyleSet()
        let segmentPoints = routeSegmentPoints(pathList: pathList)
        
        var segments: [RouteSegment] = [RouteSegment]()
        var styleIndex: UInt = 0
        for points in segmentPoints {
            // 경로 포인트로 RouteSegment 생성. 사용할 스타일 인덱스도 지정한다.
            let seg = RouteSegment(points: points, styleIndex: styleIndex)
            segments.append(seg)
            styleIndex = (styleIndex + 1) % 4
        }
        
        let options = RouteOptions(routeID: "CarRouteLayer", styleID: "routeStyleSet1", zOrder: 0)
        options.segments = segments
        let route = layer?.addRoute(option: options)
        route?.show()
        
        let pnt = segments[0].points[0]
        mapView.moveCamera(CameraUpdate.make(target: pnt, zoomLevel: 15, mapView: mapView))
    }
    
    /// 보도 경로 그리기
    private func drawPedRoute(features: [Feature]) {
        removeRouteLayer(layerID: "CarRouteLayer")
        removeRouteLayer(layerID: "WalkRouteLayer")

        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = mapView.getRouteManager()

        /// RouteLayer 생성
        let layer = manager.addRouteLayer(layerID: "WalkRouteLayer", zOrder: 0)

        // RouteStyleSet 생성
        createRouteStyleSet()

        // RouteSegment 생성 및 추가
        var segments: [RouteSegment] = []
        for feature in features {
            if feature.geometry.type == "LineString" {
                let points = feature.geometry.coordinates.map { MapPoint(longitude: $0[0], latitude: $0[1]) }
                let segment = RouteSegment(points: points, styleIndex: 0)
                segments.append(segment)
            }
        }

        // Route 추가
        let options = RouteOptions(routeID: "WalkRouteLayer", styleID: "routeStyleSet1", zOrder: 0)
        options.segments = segments
        let route = layer?.addRoute(option: options)
        route?.show()
    }

    /// 위도 경도로 point
    func routeSegmentPoints(pathList: [[Double]]) -> [[MapPoint]] {
        var segments = [[MapPoint]]()
        
        var points = [MapPoint]()
        
        _ = pathList.map { point in
            points.append(MapPoint(longitude: point[0], latitude: point[1]))
        }
        
        segments.append(points)
      
        return segments
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationServiceAuthorized = status
        if locationServiceAuthorized == .authorizedWhenInUse && (mode == .show || mode == .tracking) {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentPosition.longitude = locations[0].coordinate.longitude
        currentPosition.latitude = locations[0].coordinate.latitude
        guard let location = locations.last else { return }
        let newCoordinate = location.coordinate
        if currentLocation == nil {
            currentLocation = newCoordinate
            moveCameraToCoordinate(newCoordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        currentHeading = newHeading.trueHeading * Double.pi / 180.0
    }
}
// MARK: - 지도 관련 함수
extension FindRoadViewController {
    
    /// 선택한 좌표로 카메라 옮기기
    private func moveCameraToCoordinate(_ coordinate: CLLocationCoordinate2D) {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }
        mapView.animateCamera(cameraUpdate: CameraUpdate.make(target: MapPoint(longitude: coordinate.longitude,
                                                                               latitude: coordinate.latitude), mapView: mapView), options: CameraAnimationOptions(autoElevation: false, consecutive: true, durationInMillis: 1000))
        
    }
}
extension FindRoadViewController: GuiEventDelegate {
    func guiDidTapped(_ gui: KakaoMapsSDK.GuiBase, componentName: String) {
        //        let mapView = mapController?.getView("mapview") as! KakaoMap
        let button = gui.getChild(componentName) as? GuiButton
        switch mode {
        case .hidden:
            mode = .show   // 현위치마커 표시
            button?.image = UIImage(named: "track_location_btn_pressed.png")
            timer = Timer.init(timeInterval: 0.3, target: self, selector: #selector(self.updateCurrentPositionPOI), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: RunLoop.Mode.common)
            startUpdateLocation()
            currentPositionPoi?.show()
            currentDirectionArrowPoi?.show()
            createAndStartWaveAnimation()
            moveOnce = true

        case .show:
            mode = .tracking   // 현위치마커 추적모드
            button?.image = UIImage(named: "track_location_btn_compass_on.png")
            let mapView = mapController?.getView("mapview") as? KakaoMap
            let trackingManager = mapView?.getTrackingManager()
                            trackingManager?.startTrackingPoi(currentDirectionArrowPoi!)
                                trackingManager?.isTrackingRoll = true
            currentDirectionArrowPoi?.hide()
            currentDirectionPoi?.show()

        case .tracking:
            mode = .hidden     //현위치마커 숨김
            button?.image = UIImage(named: "track_location_btn.png")
            timer?.invalidate()
            timer = nil
            stopUpdateLocation()
            currentPositionPoi?.hide()
            currentDirectionPoi?.hide()
            let mapView = mapController?.getView("mapview") as? KakaoMap
            let trackingManager = mapView?.getTrackingManager()
            trackingManager?.stopTracking()
        }
        gui.updateGui()
    }
    @objc func updateCurrentPositionPOI() {
        currentPositionPoi?.moveAt(MapPoint(longitude: currentPosition.longitude, latitude: currentPosition.latitude), duration: 150)
        currentDirectionArrowPoi?.rotateAt(currentHeading, duration: 150)
        
        if moveOnce {
            let mapView: KakaoMap = ((mapController?.getView("mapview") as? KakaoMap)!)
            mapView.moveCamera(CameraUpdate.make(target: MapPoint(longitude: currentPosition.longitude, latitude: currentPosition.latitude), mapView: mapView))
            moveOnce = false
        }
    }
    
    func startUpdateLocation() {
        if locationServiceAuthorized != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
    }
    
    func stopUpdateLocation() {
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
    }
}
