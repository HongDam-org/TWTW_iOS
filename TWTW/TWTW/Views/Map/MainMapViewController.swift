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
    //PublishRelay
    private let myLocationTappedSubject = PublishRelay<Void>()

    var myLocationTapped: ControlEvent<Void>{
        return ControlEvent(events: myLocationTappedSubject.asObservable())
    }

    // 더미 데이터
    private let dummyData: [(imageName: String, title: String, subTitle: String)] = [
        ("image", "Place 1","detail aboudPlace 1"),
        ("image", "Place 2","detail aboudPlace 2"),
        ("image", "Place 3","detail aboudPlace 3"),
        ("image", "Place 4","detail aboudPlace 4"),
        ("image", "Place 5","detail aboudPlace 5"),
        ("image", "Place 6","detail aboudPlace 6"),
        ("image", "Place 7","detail aboudPlace 7"),
        ("image", "Place 8","detail aboudPlace 8"),
        ("image", "Place 9","detail aboudPlace 9"),
        ("image", "Place 10","detail aboudPlace 10")

    ]

    //MARK -  서치바 클릭 시 보여질 새로운 UI 요소 (circularView, nearbyPlacesCollectionView, collectionView위 버튼 (중간위치 찾을 VC이동,내위치))

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
    
    private lazy var myloctaionImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "myLocation"))
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mylocationTappedAction))
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()

    @objc
    private func mylocationTappedAction() {
        myLocationTappedSubject.accept(())
    }

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
    
    /// 서치바 동작기능 변형 버튼기능 -> 검색기능
    var searchBarSearchable : Bool = true

    /// MARK: Tabbar Controller
    private lazy var tabBarViewController: TabBarController = {
        let view = TabBarController(viewHeight: self.view.frame.height)
        view.viewHeight.accept(self.view.frame.height)
        view.delegates = self
        view.selectedViewController = view.viewControllers?[0]
        return view
    }()

    private let disposeBag = DisposeBag()
    private let viewModel = MainMapViewModel()
    private var tapGesture: UITapGestureRecognizer?
    private let locationManager = CLLocationManager()
    private var initBottomheight = 0.0

    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        hideSearchUIElements()
        initBottomheight = view.bounds.height*(0.2)
        configureLocationManager()
        setupMapViewUI() //지도
        //기존 UI
        BottomSheetBind() // 맵 로드 이후

        //새로운 UI
        setupCollectionViewUI()
        setupMyLocationUI()

        //키보드
//        keyboardDisappear()
        addSubviews_TabbarController()
        view.layoutIfNeeded()
    }

    // MARK: -  View Did Appear
    override func viewDidAppear(_ animated: Bool) {
        setupMyLocationUI()

        setupSearchBar()
    }
    
    // MARK: - Add UI
    
    /// MARK: 지도 그리기
    override func addViews() {
        
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: Map.DEFAULT_POSITION)
        
        if mapController?.addView(mapviewInfo) == Result.OK {   // 지도가 다 그려진 다음 실행
            print("Success Build Map")
            createRouteStyleSet()
            createRouteline()
            createLabelLayer()
        }
    }
    
    
    // 내 위치중심으로 지도 이동
    private func myLocationAction(){
        myLocationTapped
            .subscribe(onNext: {[weak self] in
//                self?.mapView.currentLocationTrackingMode = .onWithoutHeading
            })
            .disposed(by: disposeBag)
    }

    // 키보드를 내리는 제스처 추가
    private func keyboardDisappear(){
        self.view.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                self?.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)
    }

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
    
    /// MARK: set up CollectionView UI
    private func setupCollectionViewUI() {
        addSubViews_nearbyPlacesCollectionView()
        nearbyPlacesCollectionView.dataSource = self
        nearbyPlacesCollectionView.delegate = self
    }
    
    /// MARK: set up myLocation UI
    private func setupMyLocationUI() {
        myLocationAction()
        addSubViews_myLocation()
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

    }

    /// MARK:
    private func addSubviews_TabbarController(){
        view.addSubview(tabBarViewController.view)
        tabBarViewController.didMove(toParent: self)
        configureConstraints_TabbarController()
    }

    /// MARK: Add  UI -  CollectionView
    private func addSubViews_nearbyPlacesCollectionView(){
        view.addSubview(nearbyPlacesCollectionView)
        configureConstraints_nearbyPlacesCollectionView()
    }
    
    /// MARK: Add  UI -  myLoaction
    private func addSubViews_myLocation(){
        view.addSubview(myloctaionImageView)
        configureConstraints_myLoaction()
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
            make.leading.trailing.equalToSuperview().inset(5)
        }
    }

    /// MARK:  Configure   Constraints UI - TabbarController
    private func configureConstraints_TabbarController(){
        tabBarViewController.view.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(initBottomheight)
        }
    }

    /// MARK: Configure   Constraints UI - CollectionView
    private func configureConstraints_nearbyPlacesCollectionView() {
        nearbyPlacesCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(nearbyPlacesCollectionView.snp.width).multipliedBy(0.7)
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
    /// MARK: Configure   Constraints UI - MyLoaction
    private func configureConstraints_myLoaction() {
        myloctaionImageView.snp.remakeConstraints { make in
            make.trailing.equalToSuperview().inset(5)
            make.width.height.equalTo(view.snp.width).multipliedBy(0.1)
            make.bottom.equalTo(view.snp.bottom).offset(-initBottomheight - 10)
        }
    }
    
    /// 조건이 변화했을 때 updateLayout_myloctaionImageView() 제약조건변화
    private func updateLayout_myloctaionImageView() {
        if searchBarSearchable {
            myloctaionImageView.snp.remakeConstraints { make in
                make.trailing.equalToSuperview().inset(5)
                make.width.height.equalTo(view.snp.width).multipliedBy(0.1)
                make.bottom.equalTo(view.snp.bottom).offset(-initBottomheight - 10)
            }
        } else {
            myloctaionImageView.snp.remakeConstraints { make in
                make.trailing.equalToSuperview().inset(5)
                make.width.height.equalTo(view.snp.width).multipliedBy(0.1)
                make.bottom.equalTo(nearbyPlacesCollectionView.snp.top).offset(-5)
            }
        }

        // 변경된 제약 조건 적용
        view.layoutIfNeeded()
    }

    /// MARK: Add  Gesture - Map
    private func addTapGesture_Map(){
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        mapView.addGestureRecognizer(tapGesture ?? UITapGestureRecognizer())
    }

    /// MARK: viewModel binding
    private func BottomSheetBind(){
        viewModel.checkTouchEventRelay
            .filter { [weak self] _ in
                return self?.searchBarSearchable == true
            }
            .bind { [weak self] check in
                if check {
                    // 화면 터치시 주변 UI 숨기기
                    UIView.animate(withDuration: 0.5, animations: {
                        self?.tabBarViewController.view.alpha = 0
                    }) { (completed) in
                        if completed {
                            self?.tabBarViewController.view.isHidden = true
                        }
                    }
                } else {
                    self?.tabBarViewController.view.alpha = 1
                    self?.tabBarViewController.view.isHidden = false
                }
            } .disposed(by: disposeBag)
    }

    ///MARK: -  새로운 UI 요소들을 표시하고 기존 요소들을 숨기는 함수
    private func showSearchUIElements() {
        // 기존 UI 요소 숨기기
        tabBarViewController.view.isHidden = true

        //새로운 UI요소 보이기
        nearbyPlacesCollectionView.isHidden = false
        myLocationcircular()

    }
    
    ///MARK: -  새로운 UI 요소들을 숨기고 기존 요소들을 보이게 하는 함수
    private func hideSearchUIElements() {
        // 새로운 UI 요소들 숨기기
        nearbyPlacesCollectionView.isHidden = true

        // 기존 UI 요소 보이기
        tabBarViewController.view.isHidden = false

    }

    private func myLocationcircular() {
        // 서치바를 통해 원반경을 보여줄 때
//        if searchBarSearchable, let userLocation = mapView.mapCenterPoint {
//            circularOverlay(center: userLocation, radius: 500)// 반경500m
//        }
    }

    /// MARK: 터치 이벤트 실행
    @objc
    private func handleTap(_ gesture: UITapGestureRecognizer) {
        viewModel.checkingTouchEvents()
    }
    
    
    // MARK: - Route Functions
    
    /// 길찾기 표시
    func createRouteStyleSet() {

        let mapView = mapController?.getView("mapview") as? KakaoMap
        let manager = mapView?.getRouteManager()
        let _ = manager?.addRouteLayer(layerID: "RouteLayer", zOrder: 0)
        let patternImages = [UIImage(named: "route_pattern_arrow.png"), UIImage(named: "route_pattern_walk.png"), UIImage(named: "route_pattern_long_dot.png")]
        
        // pattern
        let styleSet = RouteStyleSet(styleID: "routeStyleSet1")
        styleSet.addPattern(RoutePattern(pattern: patternImages[0]!, distance: 60, symbol: nil, pinStart: false, pinEnd: false))
        styleSet.addPattern(RoutePattern(pattern: patternImages[1]!, distance: 6, symbol: nil, pinStart: false, pinEnd: false))
//        styleSet.addPattern(RoutePattern(pattern: patternImages[2]!, distance: 6, symbol: UIImage(named: "route_pattern_long_airplane.png")!, pinStart: true, pinEnd: true))
        
        let colors = [
            UIColor(hexCode: "ff0000"),
            UIColor(hexCode: "00ff00"),
            UIColor(hexCode: "0000ff"),
            UIColor(hexCode: "ffff00") ]

        let strokeColors = [
            UIColor(hexCode: "ffffff"),
            UIColor(hexCode: "ddffdd"),
            UIColor(hexCode: "00ddff"),
            UIColor(hexCode: "ffffdd") ]
            
        let patternIndex = [-1, 0, 1, 2]
        
        for index in 0 ..< colors.count {
            let routeStyle = RouteStyle(styles: [
                PerLevelRouteStyle(width: 18, color: colors[index], strokeWidth: 4, strokeColor: strokeColors[index], level: 0, patternIndex: patternIndex[index])
            ])
 
            styleSet.addStyle(routeStyle)
        }

        manager?.addRouteStyleSet(styleSet)
    }
    
    /// MARK:  지도에 선 그리기
    func createRouteline() {
        let mapView = mapController?.getView("mapview") as! KakaoMap
        let manager = mapView.getRouteManager()
        let layer = manager.addRouteLayer(layerID: "RouteLayer", zOrder: 0)
        
        let segmentPoints = routeSegmentPoints()
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
    func routeSegmentPoints() -> [[MapPoint]] {
        var segments = [[MapPoint]]()
        
        var points = [MapPoint]()
        points.append(MapPoint(longitude: 126.7335293, latitude: 37.3401906))
        points.append(MapPoint(longitude: 126.7323429, latitude: 37.3416939))
        
        segments.append(points)
        
        points = [MapPoint]()   // 따로 표시가 됨
        points.append(MapPoint(longitude: 129.0759853,
                               latitude: 35.1794697))
        points.append(MapPoint(longitude: 129.0764276,
                               latitude: 35.1795108))
        points.append(MapPoint(longitude: 129.0762855,
                               latitude: 35.1793188))
        segments.append(points)
        return segments
    }
    
    // MARK: - Poi Functions
    
    /// POI가 속할 LabelLayer를 생성
    func createLabelLayer() {
        guard let view = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = view.getLabelManager()    //LabelManager를 가져온다. LabelLayer는 LabelManger를 통해 추가할 수 있다.
        
        let layerOption = LabelLayerOptions(layerID: "PoiLayer", competitionType: .none, competitionUnit: .poi, orderType: .rank, zOrder: 10001)
        let _ = manager.addLabelLayer(option: layerOption)
        createPoiStyle()
    }
    
    /// POI 스타일 설정
    func createPoiStyle() {
        guard let view = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = view.getLabelManager()

        let iconStyle = PoiIconStyle(symbol: UIImage(named: "route_pattern_long_dot.png")?.resize(newWidth: 30, newHeight: 30), anchorPoint: CGPoint(x: 0.0, y: 0.0))
        let perLevelStyle = PerLevelPoiStyle(iconStyle: iconStyle, level: 0)  // 이 스타일이 적용되기 시작할 레벨.
        let poiStyle = PoiStyle(styleID: "customStyle1", styles: [perLevelStyle])
        manager.addPoiStyle(poiStyle)
        createPois()
    }
    
    /// POI를 생성
    func createPois() {
        guard let view = mapController?.getView("mapview") as? KakaoMap else { return }
        let manager = view.getLabelManager()
        let layer = manager.getLabelLayer(layerID: "PoiLayer")   // 생성한 POI를 추가할 레이어를 가져온다.
        let poiOption = PoiOptions(styleID: "customStyle1") // 생성할 POI의 Option을 지정하기 위한 자료를 담는 클래스를 생성. 사용할 스타일의 ID를 지정한다.
        poiOption.rank = 0
        
        let poi1 = layer?.addPoi(option: poiOption, at: MapPoint(longitude: 126.7335293, latitude: 37.3401906), callback: nil)
        let poi2 = layer?.addPoi(option: poiOption, at: MapPoint(longitude: 126.7323429, latitude: 37.3416939), callback: nil)
        poi1?.show()
        poi2?.show()
    }
    
}

// MARK: - extension


// BottomSheetDelegate 프로토콜
extension MainMapViewController: BottomSheetDelegate {
    func didUpdateBottomSheetHeight(_ height: CGFloat) {
        tabBarViewController.view.snp.updateConstraints { make in
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

        if searchBarSearchable {
            // 처음 클릭시 새로운 UI를 보이도록 처리
            showSearchUIElements()
            searchBarSearchable = false// 검색 동작 가능하도록 플래그를 변경
            updateLayout_myloctaionImageView()
            return false
        } else {
            // 이미 검색 UI가 보이는 경우 검색 동작을 허용

            return true
        }
    }
}

// MARK: -  UICollectionViewDataSource, UICollectionViewDelegate
extension MainMapViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dummyData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NearbyPlacesCollectionViewCell.cellIdentifier, for: indexPath) as? NearbyPlacesCollectionViewCell else { return UICollectionViewCell() }

        let data = dummyData[indexPath.item]

        cell.imageView.image = UIImage(named: data.imageName)
        cell.titleLabel.text = data.title
        cell.subTitleLabel.text = data.subTitle
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
        return 2
    }
    //초기 셀 UIEdgeInsets 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }

}

extension MainMapViewController {
    // MARK: - Height Update Method

    func updateBottomSheetHeight(_ height: CGFloat) {
        tabBarViewController.updateBottomSheetHeight(height)
    }
}
