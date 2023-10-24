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
import RxGesture
import RxCocoa

final class MainMapViewModel {
    private let coordinator: DefaultMainMapCoordinator?
    private let disposeBag = DisposeBag()
    
    init(coordinator: DefaultMainMapCoordinator?) {
        self.coordinator = coordinator
    }
    
    struct Input {
        /// 지도 화면 터치 감지
        let screenTouchEvents: Observable<ControlEvent<RxGestureRecognizer>.Element>?
        
        /// 검색 버튼 터치 감지
        let searchBarTouchEvents: Observable<ControlEvent<RxGestureRecognizer>.Element>?
        
        /// Location Manager
        let cLLocationCoordinate2DEvents: Observable<CLLocationManager>?
        
        /// 내위치 버튼 눌렀을 때
        let myLocationTappedEvents: Observable<ControlEvent<RxGestureRecognizer>.Element>?
        
        /// 뷰의 중간 Y좌표
        let viewMiddleYPoint: Observable<CGFloat>?
        
        /// 내위치 버튼 Y 좌표
        let tabbarControllerViewPanEvents: Observable<ControlEvent<RxGestureRecognizer>.Element>?
    }
    
    struct Output {
        /// 탭바 가리기
        /// true: hide, false: show
        var hideTabbarControllerRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
        
        /// 검색바 가리기
        /// true: hide, false: show
        var hideSearchBarRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
        
        /// 주변 검색 결과 UI 가리기
        /// true: hide, false: show
        var hideNearPlacesRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
        
        /// 내위치 나타내는 버튼
        /// /// true: hide, false: show
        var hideMyLocationImageViewRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
        
        /// 자신의 위치 반환
        var myLocatiaonRelay: BehaviorRelay<CLLocationCoordinate2D> = BehaviorRelay(value: CLLocationCoordinate2D())
        
        /// 검색한 위치 좌표
        var cameraCoordinateObservable: BehaviorRelay<CLLocationCoordinate2D> = BehaviorRelay(value: CLLocationCoordinate2D())
        
        /// 위치 정보를 넘길때 Mainmap 주변장소 보이는 UI로 변경
        var showNearPlacesUI: BehaviorRelay<Bool> = BehaviorRelay(value: false)
        
    }
    
    /// MARK: bind
    func bind(input: Input) -> Output {
        
        return createOutput(input: input)
    }
    
    /// MARK: create output
    private func createOutput(input: Input) -> Output{
        let output = Output()
        input.screenTouchEvents?
            .bind(onNext: { _ in
                output.hideTabbarControllerRelay.accept(!output.hideTabbarControllerRelay.value)
                output.hideMyLocationImageViewRelay.accept(!output.hideMyLocationImageViewRelay.value)
                output.hideNearPlacesRelay.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.searchBarTouchEvents?
            .bind { [weak self] _ in
                guard let self = self else {return}
                moveSearch(output: output)
            }
            .disposed(by: disposeBag)
        
        input.cLLocationCoordinate2DEvents?
            .bind { manager in
                output.myLocatiaonRelay.accept(manager.location?.coordinate ?? CLLocationCoordinate2D())
            }
            .disposed(by: disposeBag)
        
        output.showNearPlacesUI
            .bind { check in
                output.hideTabbarControllerRelay.accept(check)
                output.hideMyLocationImageViewRelay.accept(check)
                output.hideNearPlacesRelay.accept(!check)
            }
            .disposed(by: disposeBag)
        
      
        touchMyLocation(input: input, output: output)
        hideImageView(input: input, output: output)
        
        return output
    }
    
    /// MARK: when touch my location
    private func touchMyLocation(input: Input, output: Output){
        guard let myLocationTappedEvents = input.myLocationTappedEvents, let cLLocationCoordinate2DEvents = input.cLLocationCoordinate2DEvents else {return}
        Observable.combineLatest(myLocationTappedEvents,
                                 cLLocationCoordinate2DEvents)
        .bind { gesture, manager in
            output.myLocatiaonRelay.accept(manager.location?.coordinate ?? CLLocationCoordinate2D())
        }
        .disposed(by: disposeBag)
    }
    
    /// MARK: hide image View
    private func hideImageView(input: Input, output: Output){
        guard let tabbarControllerViewPanEvents = input.tabbarControllerViewPanEvents, let viewMiddleYPoint = input.viewMiddleYPoint else { return }
        Observable.combineLatest(tabbarControllerViewPanEvents,
                                 viewMiddleYPoint)
        .bind { gesture, viewYOffset in
            switch gesture.state {
            case .began, .changed, .ended, .cancelled:
                if let height = gesture.view?.bounds.height, height > viewYOffset {
                    output.hideMyLocationImageViewRelay.accept(true)
                    return
                }
                output.hideMyLocationImageViewRelay.accept(false)
            default:
                return
            }
            
        }
        .disposed(by: disposeBag)
    }
    
    // MARK: - Logic
    
    /// MARK: 검색 화면으로 이동
    private func moveSearch(output: Output) {
        coordinator?.moveSearch(output: output)
    }
    
    /// MARK:  지도에 선 그리기
    func createRouteline(mapView: KakaoMap, layer: RouteLayer?, output: Output) {
        let segmentPoints = routeSegmentPoints(longitude: output.myLocatiaonRelay.value.longitude,
                                               latitude: output.myLocatiaonRelay.value.latitude)
        
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
    
    /// MARK:  위도 경도를 이용하여 point를 찍음
    func routeSegmentPoints(longitude: Double, latitude: Double) -> [[MapPoint]] {
        var segments = [[MapPoint]]()
        
        var points = [MapPoint]()
        
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
    
    
    
    
    
    
    // MARK: - 검색 기능
    
    /// MARK: 검색지 주변 장소 데이터
    var placeData: BehaviorRelay<[SearchNearByPlaces]> = BehaviorRelay(value: [])
    
    var tabbarItems: BehaviorRelay<[TabItem]> = BehaviorRelay(value: [])
    
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
}
