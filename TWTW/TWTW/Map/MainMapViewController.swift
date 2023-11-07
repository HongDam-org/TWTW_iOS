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
import RxGesture
import KakaoMapsSDK


///MainMapViewController - 지도화면
final class MainMapViewController: KakaoMapViewController {
    //MARK -  서치바 클릭 시 보여질 새로운 UI 요소 (circularView, nearbyPlacesCollectionView, collectionView위 버튼 (중간위치 찾을 VC이동,내위치))
    private let cellSpacing: CGFloat = 2
    private let cellInset: CGFloat = 5
    
    /// MARK: 목적지 근처 장소들을 보여줄 컬렉션 뷰
    private lazy var nearbyPlacesCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(NearbyPlacesCollectionViewCell.self, forCellWithReuseIdentifier: NearbyPlacesCollectionViewCell.cellIdentifier)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    /// MARK: 버튼역할의 서치바UI
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "장소, 주소 검색"
        searchBar.showsCancelButton = false
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = .white
        searchBar.layer.cornerRadius = 15
        searchBar.clipsToBounds = true
        
        ///MARK: searchBar shadow
        searchBar.layer.shadowColor = UIColor.gray.cgColor
        searchBar.layer.shadowOpacity = 0.5
        searchBar.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        searchBar.layer.shadowRadius = 1.5
        searchBar.layer.masksToBounds = false
        return searchBar
    }()
    
    private let disposeBag = DisposeBag()
    private let viewModel: MainMapViewModel
    var tabbarController: TabBarController
    
    init(viewModel: MainMapViewModel, tabbarController: TabBarController){
        self.viewModel = viewModel
        self.tabbarController = tabbarController
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBind()
    }
    
    private func setupUI(){
        setTabbarController()
        viewModel.initBottomheight.accept(view.bounds.height*(0.3))
        
        //새로운 UI
        addSubViewsNearbyPlacesCollectionView()
        addSubviewsTabbarController()
        
        // 더미 데이터 삽입
        viewModel.searchInputData_Dummy()
        addSubViewsSearchBar()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupBind(){
        moveCameraToSearchPlacesCoordinate()
        ShowNearPlacesBind()
        configureLocationManager()
        addTapGestureMap()
        bottomSheetBind()
    }
    
    private func setTabbarController(){
        tabbarController.tabBar.layoutIfNeeded()
        tabbarController.tabBar.layer.cornerRadius = 10
    }
    
    // MARK: - Add UI
    
    /// MARK: 지도 그리기
    override func addViews() {
        view.backgroundColor = .white
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: Map.DEFAULT_POSITION)
        
        if mapController?.addView(mapviewInfo) == Result.OK {   // 지도가 다 그려진 다음 실행
            print("Success Build Map")
            createRouteStyleSet()
            createRouteline()
            createLabelLayer()
        }
    }
    
    /// MARK:SearchPlaces에서 받은  좌표로 카메라 옮기기
    private func moveCameraToSearchPlacesCoordinate(){
        // cameraCoordinateObservable을 구독해서 좌표 변경 이벤트 처리
        viewModel.cameraCoordinateObservable?
            .subscribe(onNext: { [weak self] coordinate in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self?.moveCameraToCoordinate(coordinate)
                }
            })
            .disposed(by: disposeBag)
    }
    
    /// MARK:선택한 좌표로 카메라 옮기기
    private func moveCameraToCoordinate(_ coordinate: CLLocationCoordinate2D) {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }
        
        mapView.animateCamera(cameraUpdate: CameraUpdate.make(target: MapPoint(longitude: coordinate.longitude, latitude: coordinate.latitude), zoomLevel: 15, rotation: 1.7, tilt: 0.0, mapView: mapView), options: CameraAnimationOptions(autoElevation: true, consecutive: true, durationInMillis: 2000))
    }
    
    /// MARK: configureLocationManager
    private func configureLocationManager() {
        viewModel.locationManager.value.delegate = self
        viewModel.locationManager.value.requestWhenInUseAuthorization()
    }
    // MARK: - addSubViews
    
    /// MARK: Add  UI - SearchBar
    private func addSubViewsSearchBar(){
        view.addSubview(searchBar)
        searchBar.delegate = self
        configureConstraintsSearchBar()
        view.bringSubviewToFront(searchBar)
    }
    
    /// MARK:
    private func addSubviewsTabbarController(){
        view.addSubview(tabbarController.view)
        tabbarController.delegates = self
        tabbarController.didMove(toParent: self)
        configureConstraintsTabbarController()
    }
    
    /// MARK: Add  UI -  CollectionView
    private func addSubViewsNearbyPlacesCollectionView(){
        view.addSubview(nearbyPlacesCollectionView)
        nearbyPlacesCollectionView.dataSource = self
        nearbyPlacesCollectionView.delegate = self
        configureConstraintsNearbyPlacesCollectionView()
    }
    
    
    // MARK: - Constraints
    
    /// MARK: Configure   Constraints UI - SearchBar
    private func configureConstraintsSearchBar() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.trailing.equalToSuperview().inset(5)
        }
    }
    
    /// MARK:  Configure   Constraints UI - TabbarController
    private func configureConstraintsTabbarController(){
        tabbarController.view.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(viewModel.initBottomheight.value)
            make.bottom.equalToSuperview()//(view.safeAreaLayoutGuide)
        }
    }
    
    /// MARK: Configure   Constraints UI - CollectionView
    private func configureConstraintsNearbyPlacesCollectionView() {
        nearbyPlacesCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(nearbyPlacesCollectionView.snp.width).multipliedBy(0.7)
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
    /// MARK: Add  Gesture - Map
    private func addTapGestureMap(){
        viewModel.tapGesture.accept(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
        mapView.addGestureRecognizer(viewModel.tapGesture.value)
    }
    
    /// MARK: 내위치 탭 했을 때
    private func mylocationTappedAction() {
        if let currentLocation = viewModel.locationManager.value.location?.coordinate {
            moveCameraToCoordinate(currentLocation)
        }
        createPolygonStyleSet()
    }
    
    private func ShowNearPlacesBind(){
        viewModel.showNearPlacesUI
            .subscribe(onNext: {[weak self] showNears in
                guard let self = self else { return }
                if showNears{
                    self.showSearchUIElements()
                }
                else{
                    self.hideSearchUIElements()
                }
            }).disposed(by: disposeBag)
    }
    
    /// MARK: viewModel binding
    private func bottomSheetBind(){
        viewModel.checkTouchEventRelay
            .bind { [weak self] check in
                guard let self = self else { return }
                let isShowNearPlacesUI = self.viewModel.showNearPlacesUI.value
                if check {
                    if !isShowNearPlacesUI {
                        let tapLocation = self.viewModel.tapGesture.value.location(in: self.view)
                        let myloctaionImageViewFrame = self.tabbarController.myloctaionImageView.frame
                        
                        // 탭 위치가 myloctaionImageView의 프레임 내에 있는지 확인
                        if myloctaionImageViewFrame.contains(CGPoint(x: tapLocation.x, y: -6)) {
                            self.mylocationTappedAction()
                        }else{
                            self.handleTabbarVisibility(hide: true)}
                    } else {
                        self.handleNearbyPlacesVisibility(hide: true)
                    }
                } else {
                    if isShowNearPlacesUI {
                        self.handleNearbyPlacesVisibility(hide: false)
                    } else {
                        self.handleTabbarVisibility(hide: false)
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    ///MARK: 화면터치 시 show/hide UI
    private func handleTabbarVisibility(hide: Bool){
        UIView.animate(withDuration: 0.2, animations: {
            self.tabbarController.view.alpha = hide ? 0 : 1
        })  { (completed) in
            if completed{
                self.tabbarController.view.isHidden = hide
            }
        }
    }
    
    private func handleNearbyPlacesVisibility(hide: Bool){
        UIView.animate(withDuration: 0.2, animations: {
            self.nearbyPlacesCollectionView.alpha = hide ? 0 : 1
        }) {(completed) in
            if completed{
                self.nearbyPlacesCollectionView.isHidden = hide
            }
        }
    }
    
    ///MARK: -  새로운 UI 요소들을 표시하고 기존 요소들을 숨기는 함수
    private func showSearchUIElements() {
        tabbarController.view.isHidden = true
        nearbyPlacesCollectionView.isHidden = false
    }
    
    ///MARK: -  Searchplaces에서 목적지 만든 이후 새로운 UI 요소들을 숨기고 기존 요소들을 보이기
    private func hideSearchUIElements() {
        nearbyPlacesCollectionView.isHidden = true
        tabbarController.view.isHidden = false
    }
    
    /// MARK: 터치 이벤트 실행
    @objc
    private func handleTap(_ gesture: UITapGestureRecognizer) {
        viewModel.checkingTouchEvents()
    }
    
    // MARK: - Route Functions
    
    /// MARK: 길찾기 표시
    private func createRouteStyleSet() {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }
        // 라우트 매니저 초기화
        let manager = mapView.getRouteManager()
        // 라우트 레이어 추가
        let _ = manager.addRouteLayer(layerID: "RouteLayer", zOrder: 0)
        // 라인 패턴 이미지 배열
        let patternImages = [UIImage(named: "route_pattern_arrow.png"), UIImage(named: "route_pattern_walk.png"), UIImage(named: "route_pattern_long_dot.png")]
        
        // pattern
        let styleSet = RouteStyleSet(styleID: "routeStyleSet1")
        styleSet.addPattern(RoutePattern(pattern: patternImages[0]!, distance: 60, symbol: nil, pinStart: false, pinEnd: false))
        styleSet.addPattern(RoutePattern(pattern: patternImages[1]!, distance: 6, symbol: nil, pinStart: false, pinEnd: false))
        
        let routeStyle = RouteStyle(styles: [
            PerLevelRouteStyle(width: 15, color: UIColor.mapLineColor ?? .clear, strokeWidth: 4, strokeColor: UIColor.mapStrokeColor ?? .clear, level: 0, patternIndex: 0)
        ])
        
        styleSet.addStyle(routeStyle)
        
        manager.addRouteStyleSet(styleSet)
    }
    
    /// MARK:  지도에 선 그리기
    private func createRouteline() {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = mapView.getRouteManager()
        let layer = manager.addRouteLayer(layerID: "RouteLayer", zOrder: 0)
        
        viewModel.createRouteline(mapView: mapView, layer: layer)
    }
    
    
    // MARK: - Poi Functions
    
    /// MARK: POI가 속할 LabelLayer를 생성
    private func createLabelLayer() {
        guard let view = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = view.getLabelManager()    //LabelManager를 가져온다. LabelLayer는 LabelManger를 통해 추가할 수 있다.
        
        let layerOption = LabelLayerOptions(layerID: "PoiLayer", competitionType: .none, competitionUnit: .poi, orderType: .rank, zOrder: 10001)
        let _ = manager.addLabelLayer(option: layerOption)
        createPoiStyle()
    }
    
    /// MARK: POI 스타일 설정
    private func createPoiStyle() {
        guard let view = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = view.getLabelManager()
        
        let iconStyle = PoiIconStyle(symbol: UIImage(named: "route_pattern_long_dot.png")?.resize(newWidth: 15, newHeight: 15), anchorPoint: CGPoint(x: 0.0, y: 0.0))
        let perLevelStyle = PerLevelPoiStyle(iconStyle: iconStyle, level: 0)  // 이 스타일이 적용되기 시작할 레벨.
        let poiStyle = PoiStyle(styleID: "customStyle1", styles: [perLevelStyle])
        manager.addPoiStyle(poiStyle)
        createPois()
    }
    
    /// MARK:  POI를 생성
    private func createPois() {
        guard let view = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = view.getLabelManager()
        let layer = manager.getLabelLayer(layerID: "PoiLayer")   // 생성한 POI를 추가할 레이어를 가져온다.
        let poiOption = PoiOptions(styleID: "customStyle1") // 생성할 POI의 Option을 지정하기 위한 자료를 담는 클래스를 생성. 사용할 스타일의 ID를 지정한다.
        poiOption.rank = 0
        let longitude: Double = viewModel.locationManager.value.location?.coordinate.longitude.magnitude ?? 0.0
        let latitude: Double = viewModel.locationManager.value.location?.coordinate.latitude.magnitude ?? 0.0
        let poi1 = layer?.addPoi(option: poiOption, at: MapPoint(longitude: longitude, latitude: latitude), callback: nil)
        let poi2 = layer?.addPoi(option: poiOption, at: MapPoint(longitude: 126.7323429, latitude: 37.3416939), callback: nil)
        poi1?.show()
        poi2?.show()
    }
    
    // MARK: - PolyGon
    
    /// MARK: Draw Polygon Style Set
    private func createPolygonStyleSet() {
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
        
        createShape()
    }
    
    /// MARK: Draw Polygon Shpae
    private func createShape() {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = mapView.getShapeManager()
        let layer = manager.addShapeLayer(layerID: "shapeLayer", zOrder: 10001)
        
        let points = Primitives.getCirclePoints(radius: 500, numPoints: 90, cw: true)
        let polygon = Polygon(exteriorRing: points, hole: nil, styleIndex: 0)
        
        let longitude: Double = viewModel.locationManager.value.location?.coordinate.longitude.magnitude ?? 0.0
        let latitude: Double = viewModel.locationManager.value.location?.coordinate.latitude.magnitude ?? 0.0
        
        let options = PolygonShapeOptions(shapeID: "CircleShape", styleID: "aroundMyPoistion", zOrder: 1)
        options.basePosition = MapPoint(longitude: longitude, latitude: latitude)
        options.polygons.append(polygon)
        
        let shape = layer?.addPolygonShape(options)
        shape?.show()
        
        removePolygon()
    }
    
    /// MARK: Polygon 제거
    /// 2초뒤 자동으로 사라짐
    private func removePolygon(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else {return}
            guard let mapView = self.mapController?.getView("mapview") as? KakaoMap else { return }
            let manager = mapView.getShapeManager()
            manager.removeShapeLayer(layerID: "shapeLayer")
        }
    }
}

// MARK: - extension

// BottomSheetDelegate 프로토콜
extension MainMapViewController: BottomSheetDelegate {
    func didUpdateBottomSheetHeight(_ height: CGFloat) {
        tabbarController.view.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension MainMapViewController: CLLocationManagerDelegate {
    /// 위치 권한 확인 변화 됐을 때 실행
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkAuthorizationStatus()
    }
    
    /// 위치 권한 확인을 위한 메소드 checkAuthorizationStatus()
    private func checkAuthorizationStatus() {
        let status = viewModel.locationManager.value.authorizationStatus
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("위치 서비스 권한이 허용")
            // 위치 관련 작업 수행
        case .denied, .restricted:
            print("위치 서비스 권한이 거부")
        case .notDetermined:
            print("위치 서비스 권한이 아직 결정되지 않음")
            viewModel.locationManager.value.requestWhenInUseAuthorization()
        default:
            fatalError("알 수 없는 권한 상태")
        }
    }
}

// MARK: - SearchBar Delegate
extension MainMapViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        viewModel.showSearchPlacesMap()
        return false
    }
}

// MARK: -  UICollectionViewDataSource, UICollectionViewDelegate
extension MainMapViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.placeData.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NearbyPlacesCollectionViewCell.cellIdentifier, for: indexPath) as? NearbyPlacesCollectionViewCell else { return UICollectionViewCell() }
        let data = viewModel.placeData.value[indexPath.item]
        cell.imageView.image = UIImage(named: data.imageName ?? "")
        cell.titleLabel.text = data.title ?? ""
        cell.subTitleLabel.text = data.subTitle ?? ""
        return cell
    }
}


// MARK: - UICollectionViewDelegateFlowLayout
extension MainMapViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (collectionView.frame.width - 4 - 5) / 2.3
        let itemHeight = itemWidth * 1.5
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    //셀사이 간격: 2
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    //초기 셀 UIEdgeInsets 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: cellInset, bottom: 0, right: cellInset)
    }
}
