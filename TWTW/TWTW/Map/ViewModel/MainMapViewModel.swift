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
    private let routeService: RouteProtocol?
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
        
        /// 주변 장소 선택한 경우
        let surroundSelectedTouchEvnets: Observable<IndexPath>?
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
       // var hideNearPlacesRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
        
        /// 내위치 나타내는 버튼
        /// true: hide, false: show
        var hideUIComponetsRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
        
        /// 자신의 위치 반환
        var myLocatiaonRelay: BehaviorRelay<CLLocationCoordinate2D> = BehaviorRelay(value: CLLocationCoordinate2D())
        
        /// 검색한 위치 좌표
        var cameraCoordinateObservable: BehaviorRelay<CLLocationCoordinate2D> = BehaviorRelay(value: CLLocationCoordinate2D())
        
        /// 검색지 주변 장소 데이터 리스트
        var nearByplaceRelay: BehaviorRelay<[PlaceInformation]> = BehaviorRelay(value: [])
        
        /// 목적지 까지의 경로
        var destinationPathRelay: BehaviorRelay<[[Double]]> = BehaviorRelay(value: [[]])
        
        var moveSearchCoordinator: PublishSubject<Bool> = PublishSubject()
    }

    // MARK: - init
    init(coordinator: DefaultMainMapCoordinator?, routeService: RouteProtocol) {
        self.coordinator = coordinator
        self.routeService = routeService
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
                output.hideSearchBarRelay.accept(!output.hideSearchBarRelay.value)
                output.hideTabbarControllerRelay.accept(!output.hideTabbarControllerRelay.value)
                output.hideUIComponetsRelay.accept(!output.hideUIComponetsRelay.value)
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
        
        input.surroundSelectedTouchEvnets?
            .bind { [weak self] indexPath in
                guard let self = self else { return }
                let myLocation = output.myLocatiaonRelay.value
                let selectedItem = output.nearByplaceRelay.value[indexPath.row]
                let destinationLocation = CLLocationCoordinate2D(latitude: selectedItem.yPosition ?? 0.0,
                                                                 longitude: selectedItem.xPosition ?? 0.0)
                let body = CarRouteRequest(start: "\(myLocation.longitude),\(myLocation.latitude)",
                                           end: "\(destinationLocation.longitude),\(destinationLocation.latitude)",
                                           way: "",
                                           option: "TRAFAST",
                                           fuel: "DIESEL",
                                           car: 1)
                getCarRoute(body: body, output: output)
            }
            .disposed(by: disposeBag)
        
            touchMyLocation(input: input, output: output)

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
  
    
    // MARK: - Logic
    
    /// 검색 화면으로 이동
    private func moveSearch(output: Output) {
        coordinator?.moveSearch(output: output)
    }
    
    /// 자동차 경로 가져오기
    private func getCarRoute(body: CarRouteRequest, output: Output) {
        routeService?.carRoute(request: body)
            .subscribe(onNext: { route in
                output.destinationPathRelay.accept(route.route?.trafast?.first?.path ?? [])
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
}
