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
    
    // MARK: - UI Property
    
    /// MARK: 목적지 근처 장소들을 보여줄 컬렉션 뷰
    private lazy var nearbyPlacesCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(NearbyPlacesCollectionViewCell.self, forCellWithReuseIdentifier: NearbyPlacesCollectionViewCell.cellIdentifier)
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = false
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
        searchBar.searchTextField.isUserInteractionEnabled = false
        
        ///MARK: searchBar shadow
        searchBar.layer.shadowColor = UIColor.gray.cgColor
        searchBar.layer.shadowOpacity = 0.5
        searchBar.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        searchBar.layer.shadowRadius = 1.5
        searchBar.layer.masksToBounds = false
        return searchBar
    }()
    
    /// MARK: 내위치로 이동하기 이미지버튼
    private lazy var myloctaionImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "myLocation"))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let disposeBag = DisposeBag()
    private let viewModel: MainMapViewModel
    private let tabbarController: TabBarController
    
    // MARK: - init
    
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
    }
    
    /// MARK: 지도 그리기
    override func addViews() {
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: Map.DEFAULTPOSITION)
        
        if mapController?.addView(mapviewInfo) == Result.OK {   // 지도가 다 그려진 다음 실행
            print("Success Build Map")
            bind()
        }
    }
    
    // MARK: - Set Up
    
    /// MARK: Setting UI
    private func setupUI(){
        addSubViewsNearbyPlacesCollectionView()
        addSubviewsTabBarItemsCollectionView()
        addSubViewsSearchBar()
        addSubViewsMyloctaionImageView()
        
        // 더미 데이터 삽입
//        viewModel.searchInputData_Dummy()
        
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    // MARK: - addSubViews
    
    /// MARK: Add  UI - SearchBar
    private func addSubViewsSearchBar(){
        view.addSubview(searchBar)
        view.bringSubviewToFront(searchBar)
        configureConstraintsSearchBar()
    }
    
    /// MARK: Add  UI -  TabBarItemsCollectionView
    private func addSubviewsTabBarItemsCollectionView(){
        view.addSubview(tabbarController.view)
        tabbarController.didMove(toParent: self)
        tabbarController.delegates = self
        configureConstraintsTabbarController()
    }
    
    /// MARK: Add  UI -  CollectionView
    private func addSubViewsNearbyPlacesCollectionView(){
        view.addSubview(nearbyPlacesCollectionView)
        bindingNearByCollectionView()
        configureConstraintsNearbyPlacesCollectionView()
    }
    
    /// MARK:  Add  UI -  MyloctaionImageView
    private func addSubViewsMyloctaionImageView(){
        view.addSubview(myloctaionImageView)
        configureConstraintsMyloctaionImageView()
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
            make.height.equalTo(view.bounds.height*(0.4))
            make.bottom.equalToSuperview()
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
    
    /// MARK: Configure   Constraints UI - MyloctaionImageView
    private func configureConstraintsMyloctaionImageView(){
        myloctaionImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(5)
            make.bottom.equalTo(tabbarController.view.snp.top).offset(-5) // 바텀시트와 5 포인트 떨어진 위치에 배치
            make.width.height.equalTo(view.snp.width).dividedBy(10) // 이미지 크기 설정
        }
    }
    
    /// MARK: configureLocationManager
    private func configureLocationManager() -> CLLocationManager {
        let cLLocationManager = CLLocationManager()
        cLLocationManager.delegate = self
        cLLocationManager.requestWhenInUseAuthorization()
        return cLLocationManager
    }
    
    
    
    // MARK: - ViewModel bind
    
    /// MARK: ViewModel Binding
    private func bind(){
        let input = MainMapViewModel.Input(screenTouchEvents: kMViewContainer?.rx.anyGesture(.tap()).when(.recognized).asObservable(),
                                           searchBarTouchEvents: searchBar.rx.tapGesture().when(.recognized).asObservable(),
                                           cLLocationCoordinate2DEvents: Observable.just(configureLocationManager()),
                                           myLocationTappedEvents: myloctaionImageView.rx.anyGesture(.tap()).when(.recognized).asObservable(),
                                           tabbarControllerViewPanEvents: tabbarController.view.rx.anyGesture(.pan()).asObservable())
        let output = viewModel.bind(input: input, viewMiddleYPoint: view.frame.height/2)
        
        createRoute(output: output)
        bindHideTabbarControllerRelay(output: output)
        bindHideNearPlaces(output: output)
        bindMyLocation(output: output)
        bindHideMyLocationImageViewRelay(output: output)
    }
    
    /// MARK: 경로 그리기
    private func createRoute(output: MainMapViewModel.Output){
        createRouteStyleSet()
        createRouteline(output: output)
        createLabelLayer(output: output)
    }
    
    /// MARK: 내 위치 binding
    private func bindMyLocation(output: MainMapViewModel.Output){
        output.myLocatiaonRelay
            .bind { [weak self] location in
                guard let self = self else {return}
                moveCameraToCoordinate(location, output)
            }
            .disposed(by: disposeBag)
    }
    
    /// MARK: 주변 검색 결과  숨기기 유무
    private func bindHideNearPlaces(output: MainMapViewModel.Output){
        output.hideNearPlacesRelay
            .bind{ [weak self] check in
                guard let self = self else { return }
                handleNearbyPlacesVisibility(hide: check)
            }
            .disposed(by: disposeBag)
    }
    
    /// MARK: handle NearbyPlaces Visibility
    private func handleNearbyPlacesVisibility(hide: Bool){
        UIView.animate(withDuration: 0.2, animations: {
            self.nearbyPlacesCollectionView.alpha = hide ? 0 : 1
        }) {(completed) in
            if completed{
                self.nearbyPlacesCollectionView.isHidden = hide
            }
        }
    }
    
    /// MARK: 탭바 숨기기 유무
    private func bindHideTabbarControllerRelay(output: MainMapViewModel.Output){
        output.hideTabbarControllerRelay
            .bind { [weak self] check in
                guard let self = self else {return}
                handleTabbarVisibility(hide: check)
            }
            .disposed(by: disposeBag)
        
    }
    
    ///MARK: 화면터치 시 show/hide UI
    private func handleTabbarVisibility(hide: Bool){
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard let self = self else {return}
            tabbarController.view.alpha = hide ? 0 : 1
        })  { [weak self] _ in
            guard let self = self else {return}
            tabbarController.view.isHidden = hide
        }
    }
    
    /// MARK: 내위치 버튼 유무
    private func bindHideMyLocationImageViewRelay(output: MainMapViewModel.Output){
        output.hideMyLocationImageViewRelay
            .bind { [weak self] check in
                guard let self = self else {return}
                handleMyLocationImageView(hide: check)
            }
            .disposed(by: disposeBag)
    }
    
    ///MARK: 화면터치 시 show/hide UI
    private func handleMyLocationImageView(hide: Bool){
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            guard let self = self else {return}
            myloctaionImageView.alpha = hide ? 0 : 1
        })  { [weak self] _ in
            guard let self = self else {return}
            myloctaionImageView.isHidden = hide
        }
    }
    
    /// MARK: NearbyPlacesCollectionView binding
    private func bindingNearByCollectionView(){
        viewModel.placeData
            .bind(to: nearbyPlacesCollectionView.rx
                .items(cellIdentifier: NearbyPlacesCollectionViewCell.cellIdentifier,
                       cellType: NearbyPlacesCollectionViewCell.self))
        { row, element, cell in
            cell.imageView.image = UIImage(named: element.imageName ?? "")
            cell.titleLabel.text = element.title ?? ""
            cell.subTitleLabel.text = element.subTitle ?? ""
        }
        .disposed(by: disposeBag)
        
        nearbyPlacesCollectionView.rx.itemSelected
            .bind(onNext: { [weak self] indexPath in
                guard let self = self else {return}
                print(indexPath)
                nearbyPlacesCollectionView.deselectItem(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
        
        nearbyPlacesCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
}



// MARK: - 지도 관련 함수
extension MainMapViewController {
    
    /// MARK:선택한 좌표로 카메라 옮기기
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
    private func createRouteline(output: MainMapViewModel.Output) {
        guard let mapView = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = mapView.getRouteManager()
        let layer = manager.addRouteLayer(layerID: "RouteLayer", zOrder: 0)
        
        viewModel.createRouteline(mapView: mapView, layer: layer, output: output)
    }
    
    
    // MARK: - Poi Functions
    
    /// MARK: POI가 속할 LabelLayer를 생성
    private func createLabelLayer(output: MainMapViewModel.Output) {
        guard let view = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = view.getLabelManager()    //LabelManager를 가져온다. LabelLayer는 LabelManger를 통해 추가할 수 있다.
        
        let layerOption = LabelLayerOptions(layerID: "PoiLayer", competitionType: .none, competitionUnit: .poi, orderType: .rank, zOrder: 10001)
        let _ = manager.addLabelLayer(option: layerOption)
        createPoiStyle(output: output)
    }
    
    /// MARK: POI 스타일 설정
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
    
    /// MARK:  POI를 생성
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
    
    /// MARK: Draw Polygon Style Set
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
    
    /// MARK: Draw Polygon Shpae
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

// MARK: - BottomSheetDelegate
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

// MARK: - UICollectionViewDelegateFlowLayout
extension MainMapViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == nearbyPlacesCollectionView{
            let itemWidth = (collectionView.frame.width - 9) / 2.3
            let itemHeight = itemWidth * 1.5
            return CGSize(width: itemWidth, height: itemHeight)
        }
        else if collectionView == tabbarController.view {
            let itemWidth = collectionView.frame.width / 5
            let itemHeight = collectionView.frame.height
            return CGSize(width: itemWidth, height: itemHeight)
        }
        return CGSize()
    }
    
    //셀사이 간격: 2
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == nearbyPlacesCollectionView{
            return 2
        }
        return 0
    }
    
    //초기 셀 UIEdgeInsets 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == nearbyPlacesCollectionView{
            return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 2)
        }
        else if collectionView == tabbarController.view {
            return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        }
        return UIEdgeInsets()
    }
}
