//
//  MainMapViewModelUnitTests.swift
//  TWTWUnitTests
//
//  Created by 정호진 on 10/24/23.
//

import XCTest
import RxSwift
import RxTest
import RxCocoa
import RxGesture
import CoreLocation

@testable import TWTW

final class MainMapViewModelUnitTests: XCTestCase {
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    private var viewModel: MainMapViewModel!

    override func setUpWithError() throws {
        viewModel = MainMapViewModel(coordinator: nil, routeService: RouteService())
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        print("Start MainMapViewModelUnitTests Unit Test")
    }

    override func tearDownWithError() throws {
        viewModel = nil
        scheduler = nil
        disposeBag = nil
    }

    /// 지도 화면 터치할 때 테스트
    func testTouchMainMap() {
        let screenTouchSubject = PublishSubject<ControlEvent<RxGestureRecognizer>.Element>()

        let input = MainMapViewModel.Input(screenTouchEvents: screenTouchSubject.asObservable(),
                                           searchBarTouchEvents: nil,
                                           cLLocationCoordinate2DEvents: nil,
                                           myLocationTappedEvents: nil,
                                           tabbarControllerViewPanEvents: nil,
                                           surroundSelectedTouchEvnets: nil)

        let output = viewModel.bind(input: input, viewMiddleYPoint: nil)

        let observerHideTabbarControllerRelay = scheduler.createObserver(Bool.self)
        let observerHideMyLocationImageViewRelay = scheduler.createObserver(Bool.self)
        let observerHideNearPlacesRelay = scheduler.createObserver(Bool.self)

        output.hideTabbarControllerRelay.bind(to: observerHideTabbarControllerRelay).disposed(by: disposeBag)
        output.hideMyLocationImageViewRelay.bind(to: observerHideMyLocationImageViewRelay).disposed(by: disposeBag)
        output.hideNearPlacesRelay.bind(to: observerHideNearPlacesRelay).disposed(by: disposeBag)

        scheduler.scheduleAt(10) { screenTouchSubject.onNext(UITapGestureRecognizer(target: nil, action: nil)) }
        scheduler.scheduleAt(100) { screenTouchSubject.onNext(UITapGestureRecognizer(target: nil, action: nil)) }
        scheduler.scheduleAt(110) { screenTouchSubject.dispose() }
        scheduler.start()

        XCTAssertEqual(observerHideNearPlacesRelay.events, [
            .next(0, true),
            .next(10, true),
            .next(100, true)])

        XCTAssertEqual(observerHideTabbarControllerRelay.events, [
            .next(0, false),
            .next(10, true),
            .next(100, false)])

        XCTAssertEqual(observerHideMyLocationImageViewRelay.events, [
            .next(0, false),
            .next(10, true),
            .next(100, false)])
    }

    /// 검색 버튼 터치할 때 테스트
    func testTouchSearchBar() {
        let searchBarTouchSubject = PublishSubject<ControlEvent<UITapGestureRecognizer>.Element>()

        let input = MainMapViewModel.Input(screenTouchEvents: nil,
                                           searchBarTouchEvents: searchBarTouchSubject.asObservable(),
                                           cLLocationCoordinate2DEvents: nil,
                                           myLocationTappedEvents: nil,
                                           tabbarControllerViewPanEvents: nil,
                                           surroundSelectedTouchEvnets: nil)

        let output = viewModel.bind(input: input, viewMiddleYPoint: nil)

        let observerMoveSearchBarSubject = scheduler.createObserver(Bool.self)

        output.moveSearchCoordinator.bind(to: observerMoveSearchBarSubject).disposed(by: disposeBag)

        scheduler.scheduleAt(10) { searchBarTouchSubject.onNext(UITapGestureRecognizer(target: self, action: nil)) }
        scheduler.scheduleAt(100) { searchBarTouchSubject.onNext(UITapGestureRecognizer(target: self, action: nil)) }
        scheduler.scheduleAt(110) { searchBarTouchSubject.dispose() }
        scheduler.start()

        XCTAssertEqual(observerMoveSearchBarSubject.events, [
            .next(10, true),
            .next(100, true)])

    }

    /// 내 위치  테스트
    func testMyLocation() {
        let cLLocationManagerMock = CLLocationManager()

        let observableLocation = scheduler.createHotObservable([
            .next(0, cLLocationManagerMock),
            .next(20, cLLocationManagerMock)
        ])

        let input = MainMapViewModel.Input(screenTouchEvents: nil,
                                           searchBarTouchEvents: nil,
                                           cLLocationCoordinate2DEvents: observableLocation.asObservable(),
                                           myLocationTappedEvents: nil,
                                           tabbarControllerViewPanEvents: nil,
                                           surroundSelectedTouchEvnets: nil)

        let output = viewModel.bind(input: input, viewMiddleYPoint: nil)

        let observerMyLocatiaonRelay = scheduler.createObserver(CLLocationCoordinate2D.self)

        output.myLocatiaonRelay.bind(to: observerMyLocatiaonRelay).disposed(by: disposeBag)

        output.myLocatiaonRelay.bind(onNext: { cLLocationCoordinate2D in
            print(cLLocationCoordinate2D)
        }).disposed(by: disposeBag)

        scheduler.start()

//        XCTAssertEqual(observerMyLocatiaonRelay.events, [.next(0,CLLocationCoordinate2D(latitude: 0, longitude: 0)) ])
    }

    /// 내위치 탭 했을때 테스트
    func testMyLocationTappedEvents() {
        let myLocationTouchSubject = PublishSubject<ControlEvent<RxGestureRecognizer>.Element>()
        let cLLocationManagerMock = CLLocationManager()

        let observableLocation = scheduler.createHotObservable([
            .next(10, cLLocationManagerMock),
            .next(100, cLLocationManagerMock),
            .next(110, cLLocationManagerMock)
        ])

        let input = MainMapViewModel.Input(screenTouchEvents: nil,
                                           searchBarTouchEvents: nil,
                                           cLLocationCoordinate2DEvents: observableLocation.asObservable(),
                                           myLocationTappedEvents: myLocationTouchSubject.asObservable(),
                                           tabbarControllerViewPanEvents: nil,
                                           surroundSelectedTouchEvnets: nil)
        let output = viewModel.bind(input: input, viewMiddleYPoint: nil)

        let observerMyLocation = scheduler.createObserver(CLLocationCoordinate2D.self).asObserver()

        scheduler.scheduleAt(10) { myLocationTouchSubject.onNext(UITapGestureRecognizer(target: nil, action: nil)) }
        scheduler.scheduleAt(100) { myLocationTouchSubject.onNext(UITapGestureRecognizer(target: nil, action: nil)) }
        scheduler.scheduleAt(110) { myLocationTouchSubject.dispose() }
        scheduler.start()

        output.myLocatiaonRelay.bind(to: observerMyLocation).disposed(by: disposeBag)

        output.myLocatiaonRelay
            .bind { cLLocationCoordinate2D in
                print(cLLocationCoordinate2D)
            }
            .disposed(by: disposeBag)
    }

    func testTabbarControllerViewPanEvents() {
        let panGestureSubject = PublishSubject<ControlEvent<RxGestureRecognizer>.Element>()

        let input = MainMapViewModel.Input(screenTouchEvents: nil,
                                           searchBarTouchEvents: nil,
                                           cLLocationCoordinate2DEvents: nil,
                                           myLocationTappedEvents: nil,
                                           tabbarControllerViewPanEvents: panGestureSubject.asObservable(),
                                           surroundSelectedTouchEvnets: nil)
        let output = viewModel.bind(input: input, viewMiddleYPoint: nil)

        scheduler.scheduleAt(10) { panGestureSubject.onNext(UIPanGestureRecognizer(target: nil, action: nil)) }
        scheduler.scheduleAt(100) { panGestureSubject.onNext(UIPanGestureRecognizer(target: nil, action: nil)) }
        scheduler.scheduleAt(110) { panGestureSubject.dispose() }

        let observerHideTabbarControllerRelay = scheduler.createObserver(Bool.self)
        output.hideTabbarControllerRelay.bind(to: observerHideTabbarControllerRelay).disposed(by: disposeBag)

        XCTAssertEqual(observerHideTabbarControllerRelay.events, [
            .next(0, false)
//            .next(100, true),
//            .next(110, true),
        ])
    }
}
