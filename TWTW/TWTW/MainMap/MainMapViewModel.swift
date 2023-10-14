//
//  MainMapViewModel.swift
//  TWTW
//
//  Created by 정호진 on 2023/08/12.
//

import Foundation
import RxSwift
import RxRelay
import CoreLocation
import UIKit
import KakaoMapsSDK

final class MainMapViewModel: NSObject {
    let coordinator: MainMapCoordinator
    
    init(coordinator: MainMapCoordinator) {
        self.coordinator = coordinator
    }
    
    /// 검색 Service
    private let searchService = SearchService()
    
    /// 지도 화면 터치 감지 Relay
    ///  true: UI 제거하기, false: UI 표시
    var checkTouchEventRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    /// MARK: 검색지 주변 장소 데이터
    var placeData: BehaviorRelay<[SearchNearByPlaces]> = BehaviorRelay(value: [])
    
    /// 서치바 동작기능 변형 버튼기능 -> 검색기능
    var searchBarSearchable: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    
    /// MARK: tabbar bottm height
    var initBottomheight: BehaviorRelay<Double> = BehaviorRelay(value: 0.0)
    
    /// MARK: 현재 자신의 위치
    let locationManager: BehaviorRelay<CLLocationManager> = BehaviorRelay(value: CLLocationManager())
    
    /// MARK: 지도 화면 터치 했을 때
    var tapGesture: BehaviorRelay<UITapGestureRecognizer> = BehaviorRelay(value: UITapGestureRecognizer())
    
    // MARK: - Logic
    
    /// MARK: checking Touch Events
    func checkingTouchEvents() {
        let check = checkTouchEventRelay.value
        checkTouchEventRelay.accept(!check)
    }
  
    
    /// MARK: 검색지 주변 장소 더미 데이터
    func searchInputData_Dummy(){
        var list = placeData.value
        
        list.append(SearchNearByPlaces(imageName: "image", title: "Place 1", subTitle: "detail aboudPlace 1"))
        list.append(SearchNearByPlaces(imageName: "image", title: "Place 2", subTitle: "detail aboudPlace 2"))
        list.append(SearchNearByPlaces(imageName: "image", title: "Place 3", subTitle: "detail aboudPlace 3"))
        list.append(SearchNearByPlaces(imageName: "image", title: "Place 4", subTitle: "detail aboudPlace 4"))
        list.append(SearchNearByPlaces(imageName: "image", title: "Place 5", subTitle: "detail aboudPlace 5"))
        list.append(SearchNearByPlaces(imageName: "image", title: "Place 6", subTitle: "detail aboudPlace 6"))
        list.append(SearchNearByPlaces(imageName: "image", title: "Place 7", subTitle: "detail aboudPlace 7"))
        list.append(SearchNearByPlaces(imageName: "image", title: "Place 8", subTitle: "detail aboudPlace 8"))
        placeData.accept(list)
    }
    
    
    // MARK: - Route
    
    /// MARK:  지도에 선 그리기
    func createRouteline(mapView: KakaoMap, layer: RouteLayer?) {
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
        
        let longitude: Double = locationManager.value.location?.coordinate.longitude.magnitude ?? 0.0
        let latitude: Double = locationManager.value.location?.coordinate.latitude.magnitude ?? 0.0
        
        points.append(MapPoint(longitude: longitude, latitude: latitude))
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
    var cameraCoordinateObservable: Observable<CLLocationCoordinate2D>?

    // SearchBar 클릭 이벤트(SearchPlacesMapCoordinator를 시작)

           func showSearchPlacesMap() {
               coordinator.showSearchPlacesMap()
           
    }
    
    
    // MARK: - API Connect
    
    /// MARK: 장소 검색 함수
    /// - Parameter word: 검색한 단어
    /// - Returns: 검색한 장소 리스트
    func searchToGetPlace(word: String) -> Observable<SearchPlaces>{
        searchService.searchPlaces(place: word, x: 0, y: 0, page: 0, categoryGroupCode: "")
    }
}

