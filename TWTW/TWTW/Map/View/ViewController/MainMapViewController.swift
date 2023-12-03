//
//  MainMapViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/11.
//

import CoreLocation
import KakaoMapsSDK
import RxCocoa
import RxGesture
import RxSwift
import SnapKit
import UIKit

/// MainMapViewController - 지도화면
final class MainMapViewController: KakaoMapViewController {
    
    // MARK: - UI Property
    
    /// 목적지 근처 장소들을 보여줄 컬렉션 뷰
    private lazy var nearbyPlacesCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(NearbyPlacesCollectionViewCell.self,
                                forCellWithReuseIdentifier: CellIdentifier.nearbyPlacesCollectionViewCell.rawValue)
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = false
        return collectionView
    }()
    
    /// 버튼역할의 서치바UI
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "장소, 주소 검색"
        searchBar.showsCancelButton = false
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = .white
        searchBar.layer.cornerRadius = 15
        searchBar.clipsToBounds = true
        searchBar.searchTextField.isUserInteractionEnabled = false
        
        // searchBar shadow
        searchBar.layer.shadowColor = UIColor.gray.cgColor
        searchBar.layer.shadowOpacity = 0.5
        searchBar.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        searchBar.layer.shadowRadius = 1.5
        searchBar.layer.masksToBounds = false
        return searchBar
    }()
    
    /// 내위치로 이동하기 이미지버튼
    private lazy var myloctaionImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "myLocation"))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let disposeBag = DisposeBag()
    private let viewModel: MainMapViewModel
    private var output: MainMapViewModel.Output?
    private let mainMapCustomTabButtonsView: MainMapCustomTabButtonsView
    // MARK: - init
    
    init(viewModel: MainMapViewModel, coordinator: DefaultMainMapCoordinator) {
        self.viewModel = viewModel
        let tabViewModel = MainMapCustomTabButtonViewModel(coordinator: coordinator)
        self.mainMapCustomTabButtonsView = MainMapCustomTabButtonsView(frame: .zero, viewModel: tabViewModel)
        super.init()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
    }
    
    /// 지도 그리기
    override func addViews() {
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: Map.DEFAULTPOSITION)
        if mapController?.addView(mapviewInfo) == Result.OK {   // 지도가 다 그려진 다음 실행
            print("Success Build Map")
            if let output = output {
                bindMyLocation(output: output)
                bindSearchPlaceLocation(output: output)
                bindHideMyLocationImageViewRelay(output: output)
                bindDestinationPathRelay(output: output)
            }
        }
    }
    
    // MARK: - Set Up
    
    /// Setting UI
    private func setupUI() {
        addSubViewsSearchBar()
        addSubViewsMyloctaionImageView()
        configureConstraintsMainMapCusomTabButtonView()
        view.backgroundColor = .white
    }
    
    
    // MARK: - addSubViews
    
    ///  Add  UI - SearchBar
    private func addSubViewsSearchBar() {
        view.addSubview(searchBar)
        view.bringSubviewToFront(searchBar)
        configureConstraintsSearchBar()
    }
    private func addSubViewsMainMapCusomTabButtonView() {
        view.addSubview(mainMapCustomTabButtonsView)
        configureConstraintsMainMapCusomTabButtonView()
    }
    
    /// Add  UI -  MyloctaionImageView
    private func addSubViewsMyloctaionImageView() {
        view.addSubview(myloctaionImageView)
        configureConstraintsMyloctaionImageView()
    }
    private func configureConstraintsMainMapCusomTabButtonView() {
        view.addSubview(mainMapCustomTabButtonsView)
        configureConstraintCsusomTabButtonView()
    }
    // MARK: - Constraints
    
    /// Configure   Constraints UI - SearchBar
    private func configureConstraintsSearchBar() {
        navigationItem.titleView = searchBar
    }
    private func configureConstraintCsusomTabButtonView() {
        mainMapCustomTabButtonsView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.35)
            make.height.equalTo(mainMapCustomTabButtonsView.snp.width).multipliedBy(0.35)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(3)
        }
    }
    
    /// Configure   Constraints UI - MyloctaionImageView
    private func configureConstraintsMyloctaionImageView() {
        myloctaionImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(view.snp.width).dividedBy(10) // 이미지 크기 설정
        }
    }
    
    /// ConfigureLocationManager
    private func configureLocationManager() -> CLLocationManager {
        let cLLocationManager = CLLocationManager()
        cLLocationManager.delegate = self
        cLLocationManager.requestWhenInUseAuthorization()
        return cLLocationManager
    }
    
    // MARK: - ViewModel bind
    /// ViewModel Binding
    private func bind() {
        let input = MainMapViewModel.Input(screenTouchEvents: kMViewContainer?.rx.anyGesture(.tap()).when(.recognized).asObservable(),
                                           searchBarTouchEvents: searchBar.rx.tapGesture().when(.recognized).asObservable(),
                                           cLLocationCoordinate2DEvents: Observable.just(configureLocationManager()),
                                           myLocationTappedEvents: myloctaionImageView.rx.anyGesture(.tap())
            .when(.recognized).asObservable(),
                                           surroundSelectedTouchEvnets: nearbyPlacesCollectionView.rx.itemSelected.asObservable())
        let output = viewModel.bind(input: input, viewMiddleYPoint: view.frame.height/2)
        self.output = output
    }
    
    /// 내 위치 binding
    private func bindMyLocation(output: MainMapViewModel.Output) {
        output.myLocatiaonRelay
            .bind { [weak self] location in
                guard let self = self else {return}
                moveCameraToCoordinate(location, output)
            }
            .disposed(by: disposeBag)
    }
    
    /// 검색된 위치 binding
    private func bindSearchPlaceLocation(output: MainMapViewModel.Output) {
        output.cameraCoordinateObservable
            .subscribe(onNext: { [weak self] coordinate in
                guard let self = self else {return}
                moveCameraToCoordinate(coordinate, output)
                
            }).disposed(by: disposeBag)
    }
    
    /// handle NearbyPlaces Visibility
    private func handleNearbyPlacesVisibility(hide: Bool) {
        UIView.animate(withDuration: 0.2,
                       animations: {
            self.nearbyPlacesCollectionView.alpha = hide ? 0 : 1
        }, completion: { completed in
            if completed {
                self.nearbyPlacesCollectionView.isHidden = hide
            }
        })
    }
    
    /// 내위치 버튼 유무
    private func bindHideMyLocationImageViewRelay(output: MainMapViewModel.Output) {
        output.hideUIComponetsRelay
            .bind { [weak self] check in
                guard let self = self else {return}
                handlehiddenView(hide: check)
            }
            .disposed(by: disposeBag)
    }
    
    /// 화면터치 시 show/hide UI
    private func handlehiddenView(hide: Bool) {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard let self = self else {return}
            searchBar.alpha = hide ? 0 : 1
            myloctaionImageView.alpha = hide ? 0 : 1
            mainMapCustomTabButtonsView.alpha = hide ? 0 : 1
        }, completion: { [weak self] _ in
            guard let self = self else {return}
            myloctaionImageView.isHidden = hide
            mainMapCustomTabButtonsView.isHidden = hide
        })
    }
    
    /// 목적지까지 경로
    private func bindDestinationPathRelay(output: MainMapViewModel.Output) {
        output.destinationPathRelay
            .subscribe(onNext: { [weak self] pathList in
                guard let self = self, pathList != [[]] else {return}
                createRouteStyleSet()
                createRouteline(pathList: pathList)
                createLabelLayer(output: output)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - 지도 관련 함수
extension MainMapViewController {
    
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
                              callback: {self.createPolygonStyleSet(output: output)})
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
    
    /// 지도에 선 그리기
    private func createRouteline(pathList: [[Double]]) {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = mapView.getRouteManager()
        let layer = manager.addRouteLayer(layerID: "RouteLayer", zOrder: 0)
        
        let segmentPoints = routeSegmentPoints(pathList: pathList)
        
        var segments: [RouteSegment] = [RouteSegment]()
        var styleIndex: UInt = 0
        for points in segmentPoints {
            // 경로 포인트로 RouteSegment 생성. 사용할 스타일 인덱스도 지정한다.
            let seg = RouteSegment(points: points, styleIndex: styleIndex)
            segments.append(seg)
            styleIndex = (styleIndex + 1) % 4
        }
        
        let options = RouteOptions(routeID: "routes", styleID: "routeStyleSet1", zOrder: 0)
        options.segments = segments
        let route = layer?.addRoute(option: options)
        route?.show()
        
        let pnt = segments[0].points[0]
        mapView.moveCamera(CameraUpdate.make(target: pnt, zoomLevel: 15, mapView: mapView))
    }
    
    
    /// 위도 경도를 이용하여 point를 찍음
    func routeSegmentPoints(pathList: [[Double]]) -> [[MapPoint]] {
        var segments = [[MapPoint]]()
        
        var points = [MapPoint]()
        
        _ = pathList.map { point in
            points.append(MapPoint(longitude: point[0], latitude: point[1]))
        }
        
        segments.append(points)
        
        //        points = [MapPoint]()   // 따로 표시가 됨
        //        points.append(MapPoint(longitude: 129.0759853,
        //                               latitude: 35.1794697))
        //        points.append(MapPoint(longitude: 129.0764276,
        //                               latitude: 35.1795108))
        //        points.append(MapPoint(longitude: 129.0762855,
        //                               latitude: 35.1793188))
        //        segments.append(points)
        return segments
    }
    
    
    // MARK: - Poi Functions
    
    /// POI가 속할 LabelLayer를 생성
    private func createLabelLayer(output: MainMapViewModel.Output) {
        guard let view = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = view.getLabelManager()    // LabelManager를 가져온다. LabelLayer는 LabelManger를 통해 추가할 수 있다.
        
        let layerOption = LabelLayerOptions(layerID: "PoiLayer",
                                            competitionType: .none,
                                            competitionUnit: .poi,
                                            orderType: .rank,
                                            zOrder: 10001)
        _ = manager.addLabelLayer(option: layerOption)
        createPoiStyle(output: output)
    }
    
    /// POI 스타일 설정
    private func createPoiStyle(output: MainMapViewModel.Output) {
        guard let view = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = view.getLabelManager()
        
        let iconStyle = PoiIconStyle(symbol: UIImage(named: "route_pattern_arrow.png")?.resize(newWidth: 15, newHeight: 15),
                                     anchorPoint: CGPoint(x: 0.0, y: 0.0))
        let perLevelStyle = PerLevelPoiStyle(iconStyle: iconStyle, level: 0)  // 이 스타일이 적용되기 시작할 레벨.
        let poiStyle = PoiStyle(styleID: "customStyle1", styles: [perLevelStyle])
        manager.addPoiStyle(poiStyle)
        createPois(output: output)
    }
    
    /// POI를 생성
    private func createPois(output: MainMapViewModel.Output) {
        guard let view = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = view.getLabelManager()
        let layer = manager.getLabelLayer(layerID: "PoiLayer")   // 생성한 POI를 추가할 레이어를 가져온다.
        let poiOption = PoiOptions(styleID: "customStyle1") // 생성할 POI의 Option을 지정하기 위한 자료를 담는 클래스를 생성. 사용할 스타일의 ID를 지정한다.
        poiOption.rank = 0
        let longitude: Double = output.myLocatiaonRelay.value.longitude.magnitude
        let latitude: Double = output.myLocatiaonRelay.value.latitude.magnitude
        let poi1 = layer?.addPoi(option: poiOption, at: MapPoint(longitude: longitude, latitude: latitude), callback: nil)
        let poi2 = layer?.addPoi(option: poiOption, at: MapPoint(longitude: 126.7323429, latitude: 37.3416939), callback: nil)
        poi1?.show()
        poi2?.show()
    }
    
    // MARK: - PolyGon
    
    /// Draw Polygon Style Set
    private func createPolygonStyleSet(output: MainMapViewModel.Output) {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = mapView.getShapeManager()
        
        // 레벨별 스타일을 생성.
        let perLevelStyle1 = PerLevelPolygonStyle(color: UIColor.mapCircleColor ?? .black,
                                                  strokeWidth: 1,
                                                  strokeColor: .clear, level: 0)
        
        let perLevelStyle2 = PerLevelPolygonStyle(color: UIColor.mapCircleColor ?? .black,
                                                  strokeWidth: 1,
                                                  strokeColor: .clear, level: 15)
        
        // 각 레벨별 스타일로 구성된 2개의 Polygon Style
        let shapeStyle1 = PolygonStyle(styles: [perLevelStyle1, perLevelStyle2])
        
        // PolygonStyle을 PolygonStyleSet에 추가.
        let shapeStyleSet = PolygonStyleSet(styleSetID: "aroundMyPoistion", styles: [shapeStyle1])
        manager.addPolygonStyleSet(shapeStyleSet)
        
        createShape(output: output)
    }
    
    /// Draw Polygon Shpae
    private func createShape(output: MainMapViewModel.Output) {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = mapView.getShapeManager()
        let layer = manager.addShapeLayer(layerID: "shapeLayer", zOrder: 10001)
        
        let points = Primitives.getCirclePoints(radius: 500, numPoints: 90, cw: true)
        let polygon = Polygon(exteriorRing: points, hole: nil, styleIndex: 0)
        
        let longitude: Double = output.myLocatiaonRelay.value.longitude.magnitude
        let latitude: Double = output.myLocatiaonRelay.value.latitude.magnitude
        
        let options = PolygonShapeOptions(shapeID: "CircleShape", styleID: "aroundMyPoistion", zOrder: 1)
        options.basePosition = MapPoint(longitude: longitude, latitude: latitude)
        options.polygons.append(polygon)
        
        let shape = layer?.addPolygonShape(options)
        shape?.show()
        
        removePolygon()
    }
    
    /// Polygon 제거
    /// 2초뒤 자동으로 사라짐
    private func removePolygon() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else {return}
            guard let mapView = self.mapController?.getView("mapview") as? KakaoMap else { return }
            let manager = mapView.getShapeManager()
            manager.removeShapeLayer(layerID: "shapeLayer")
        }
    }
}
// MARK: - CLLocationManagerDelegate
extension MainMapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorizationStatus(manager: manager)
    }
    
    /// 위치 권한 확인을 위한 메소드 checkAuthorizationStatus()
    private func checkAuthorizationStatus(manager: CLLocationManager) {
        let status = manager.authorizationStatus
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("위치 서비스 권한이 허용")
            // 위치 관련 작업 수행
        case .denied, .restricted:
            print("위치 서비스 권한이 거부")
        case .notDetermined:
            print("위치 서비스 권한이 아직 결정되지 않음")
            manager.requestWhenInUseAuthorization()
        default:
            fatalError("알 수 없는 권한 상태")
        }
    }
}
