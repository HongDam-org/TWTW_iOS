//
//  MainMapViewModel.swift
//  TWTW
//
//  Created by 정호진 on 2023/08/12.
//

import CoreLocation
import Foundation
import KakaoMapsSDK
import RxCocoa
import RxGesture
import RxRelay
import RxSwift
import UIKit

final class MainMapViewModel {
    private let coordinator: DefaultMainMapCoordinator?
    private let disposeBag = DisposeBag()
    
    struct Input {
        /// 지도 화면 터치 감지
        let screenTouchEvents: Observable<ControlEvent<RxGestureRecognizer>.Element>?
        
        /// 검색 버튼 터치 감지
        let searchBarTouchEvents: Observable<ControlEvent<UITapGestureRecognizer>.Element>?
        
        /// Location Manager
        let cLLocationCoordinate2DEvents: Observable<CLLocationManager>?
        
        /// 내위치 버튼 눌렀을 때
        let myLocationTappedEvents: Observable<ControlEvent<RxGestureRecognizer>.Element>?
        
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
        /// true: hide, false: show
        var hideMyLocationImageViewRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
        
        /// 자신의 위치 반환
        var myLocatiaonRelay: BehaviorRelay<CLLocationCoordinate2D> = BehaviorRelay(value: CLLocationCoordinate2D())
        
        /// 검색한 위치 좌표
        var cameraCoordinateObservable: BehaviorRelay<CLLocationCoordinate2D> = BehaviorRelay(value: CLLocationCoordinate2D())
        
        /// 검색지 주변 장소 데이터 리스트
        var nearByplaceRelay: BehaviorRelay<[PlaceInformation]> = BehaviorRelay(value: [])
        
        
        var moveSearchCoordinator: PublishSubject<Bool> = PublishSubject()
    }

    // MARK: - init
    init(coordinator: DefaultMainMapCoordinator?) {
        self.coordinator = coordinator
    }

    /// bind
    func bind(input: Input, viewMiddleYPoint: CGFloat?) -> Output {
        return createOutput(input: input, viewMiddleYPoint: viewMiddleYPoint)
    }
    
    /// create output
    private func createOutput(input: Input, viewMiddleYPoint: CGFloat?) -> Output {
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
                output.moveSearchCoordinator.onNext(true)
                moveSearch(output: output)
            }
            .disposed(by: disposeBag)
        
        input.cLLocationCoordinate2DEvents?
            .bind { manager in
                output.myLocatiaonRelay.accept(manager.location?.coordinate ?? CLLocationCoordinate2D())
                output.cameraCoordinateObservable.accept(manager.location?.coordinate ?? CLLocationCoordinate2D())
            }
            .disposed(by: disposeBag)
        
        output.cameraCoordinateObservable
            .subscribe(onNext: { _ in
                output.hideTabbarControllerRelay.accept(true)
                output.hideMyLocationImageViewRelay.accept(true)
                output.hideNearPlacesRelay.accept(false)
            })
            .disposed(by: disposeBag)
        
        touchMyLocation(input: input, output: output)
        
        hideImageView(input: input, output: output, viewMiddleYPoint: viewMiddleYPoint)
        
        return output
    }
    
    /// when touch my location
    private func touchMyLocation(input: Input, output: Output) {
        guard let myLocationTappedEvents = input.myLocationTappedEvents,
              let cLLocationCoordinate2DEvents = input.cLLocationCoordinate2DEvents else {return}
        Observable.combineLatest(myLocationTappedEvents,
                                 cLLocationCoordinate2DEvents)
        .bind { _, manager in
            output.myLocatiaonRelay.accept(manager.location?.coordinate ?? CLLocationCoordinate2D())
        }
        .disposed(by: disposeBag)
    }
    
    /// hide image View
    private func hideImageView(input: Input, output: Output, viewMiddleYPoint: CGFloat?) {
        input.tabbarControllerViewPanEvents?
            .bind { gesture in
                switch gesture.state {
                case .began, .changed, .ended, .cancelled:
                    if let height = gesture.view?.bounds.height, height > viewMiddleYPoint ?? 0 {
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
    
    /// 검색 화면으로 이동
    private func moveSearch(output: Output) {
        coordinator?.moveSearch(output: output)
    }
    
    /// 지도에 선 그리기
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
    
    /// 위도 경도를 이용하여 point를 찍음
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

}
