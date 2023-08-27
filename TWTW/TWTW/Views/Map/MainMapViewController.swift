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


///MainMapViewController - 지도화면
final class MainMapViewController: UIViewController  {
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
    
    // 목적지 근처 장소들을 보여줄 컬렉션 뷰
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
    
    @objc private func mylocationTappedAction() {
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
    var searchBarSearchable : Bool = true //서치바 동작기능 변형 버튼기능->검색기능
    
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
        hideSearchUIElements()
        initBottomheight = view.bounds.height*(0.2)
        configureLocationManager()
        setupMapViewUI() // 지도
        //기존 UI
        BottomSheetBind() // 맵 로드 이후
        
        //새로운 UI
        setupCollectionViewUI()
        setupMyLocationUI()
        
        //키보드
        keyboardDisappear()
        
        
        view.layoutIfNeeded()
        
        
        
    }
    
    // MARK: -  View Did Appear
    override func viewDidAppear(_ animated: Bool) {
        setupMyLocationUI()
        
        addSubViews_BottomSheet()
        setupSearchBar()
        
        
        
    }
    
    // MARK: - Fuctions
    // 내 위치중심으로 지도 이동
    private func myLocationAction(){
        myLocationTapped
            .subscribe(onNext: {[weak self] in
                self?.mapView.currentLocationTrackingMode = .onWithoutHeading
             
            })
            .disposed(by: disposeBag)
    }

    
    // 내 위치중심으로 원반경 추가
    private func circularOverlay(center: MTMapPoint, radius: Double){
        let circle = MTMapCircle()
        circle.circleCenterPoint = center
        circle.circleRadius = Float(radius)
        circle.circleFillColor = UIColor.mapCircleColor
        circle.circleLineWidth = 0.0
        circle.circleLineColor = .clear
        
        mapView.addCircle(circle)
        
        
    }

    
    
    // 키보드를 내리는 제스처 추가
    private func keyboardDisappear(){
        let tapGestureToDismissKeyboard = UITapGestureRecognizer()
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
    /// MARK: Add  UI - BottomSheet
    private func addSubViews_BottomSheet() {
        view.addSubview(bottomSheetViewController.view)
        bottomSheetViewController.didMove(toParent: self)
        configureConstraints_BottomSheet()
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
    /// MARK: Configure  Constraints UI - BottomSheet
    private func configureConstraints_BottomSheet() {
        bottomSheetViewController.view.snp.makeConstraints { make in
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
    // 조건이 변화했을 때 updateLayout_myloctaionImageView() 제약조건변화
    func updateLayout_myloctaionImageView() {
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
    
    ///MARK: Add  Gesture - Map
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
                        self?.bottomSheetViewController.view.alpha = 0
                    }) { (completed) in
                        if completed {
                            self?.bottomSheetViewController.view.isHidden = true
                        }
                    }
                } else {
                    self?.bottomSheetViewController.view.alpha = 1
                    self?.bottomSheetViewController.view.isHidden = false
                }
            } .disposed(by: disposeBag)
    }
    
    ///MARK: -  새로운 UI 요소들을 표시하고 기존 요소들을 숨기는 함수
    private func showSearchUIElements() {
        // 기존 UI 요소 숨기기
        bottomSheetViewController.view.isHidden = true
        
        //새로운 UI요소 보이기
        nearbyPlacesCollectionView.isHidden = false
        myLocationcircular()
        
    }
    ///MARK: -  새로운 UI 요소들을 숨기고 기존 요소들을 보이게 하는 함수
    private func hideSearchUIElements() {
        // 새로운 UI 요소들 숨기기
        nearbyPlacesCollectionView.isHidden = true
        
        // 기존 UI 요소 보이기
        bottomSheetViewController.view.isHidden = false

    }
    private func myLocationcircular() {
        // 서치바를 통해 원반경을 보여줄 때
        if searchBarSearchable, let userLocation = mapView.mapCenterPoint {
            circularOverlay(center: userLocation, radius: 500)// 반경500m
        }
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NearbyPlacesCollectionViewCell.cellIdentifier, for: indexPath) as! NearbyPlacesCollectionViewCell
        
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

