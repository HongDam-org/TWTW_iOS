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

@testable import TWTW

final class MainMapViewModelUnitTests: XCTestCase {

    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    private var viewModel: MainMapViewModel!
//    private var input: MainMapViewModel.Input!
//    private var output: MainMapViewModel.Output!
    
    override func setUpWithError() throws {
        viewModel = MainMapViewModel(coordinator: nil)
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
    func testTouchMainMap(){
        let screenTouchSubject = PublishSubject<ControlEvent<RxGestureRecognizer>.Element>()
    
        let input = MainMapViewModel.Input(screenTouchEvents: screenTouchSubject.asObservable(),
                                           searchBarTouchEvents: nil,
                                           cLLocationCoordinate2DEvents: nil,
                                           myLocationTappedEvents: nil,
                                           viewMiddleYPoint: nil,
                                           tabbarControllerViewPanEvents: nil)
        
        let output = viewModel.bind(input: input)
        
        let observerHideTabbarControllerRelay = scheduler.createObserver(Bool.self)
        let observerHideMyLocationImageViewRelay = scheduler.createObserver(Bool.self)
        let observerHideNearPlacesRelay = scheduler.createObserver(Bool.self)
        
        output.hideTabbarControllerRelay.bind(to:observerHideTabbarControllerRelay).disposed(by: disposeBag)
        output.hideMyLocationImageViewRelay.bind(to:observerHideMyLocationImageViewRelay).disposed(by: disposeBag)
        output.hideNearPlacesRelay.bind(to:observerHideNearPlacesRelay).disposed(by: disposeBag)
        
        scheduler.scheduleAt(10) { screenTouchSubject.onNext(UITapGestureRecognizer(target: nil, action: nil)) }
        scheduler.scheduleAt(100) { screenTouchSubject.onNext(UITapGestureRecognizer(target: nil, action: nil)) }
        scheduler.scheduleAt(110) { screenTouchSubject.dispose() }
        scheduler.start()
        
        XCTAssertEqual(observerHideNearPlacesRelay.events, [
            .next(0,true),
            .next(10,true),
            .next(100,true)])
        
        XCTAssertEqual(observerHideTabbarControllerRelay.events, [
            .next(0,false),
            .next(10,true),
            .next(100,false)])
        
        XCTAssertEqual(observerHideMyLocationImageViewRelay.events, [
            .next(0,false),
            .next(10,true),
            .next(100,false)])
        
    }
    
    
    /// 지도 화면 터치할 때 테스트
    func testTouchSearchBar(){
        let searchBarTouchSubject = PublishSubject<ControlEvent<RxGestureRecognizer>.Element>()
    
        let input = MainMapViewModel.Input(screenTouchEvents: nil,
                                           searchBarTouchEvents: searchBarTouchSubject.asObservable(),
                                           cLLocationCoordinate2DEvents: nil,
                                           myLocationTappedEvents: nil,
                                           viewMiddleYPoint: nil,
                                           tabbarControllerViewPanEvents: nil)
        
        let output = viewModel.bind(input: input)
        
        let observerMoveSearchBarSubject = scheduler.createObserver(Bool.self)
        
        output.moveSearchCoordinator.bind(to:observerMoveSearchBarSubject).disposed(by: disposeBag)
        
        scheduler.scheduleAt(10) { searchBarTouchSubject.onNext(UITapGestureRecognizer(target: nil, action: nil)) }
        scheduler.scheduleAt(100) { searchBarTouchSubject.onNext(UITapGestureRecognizer(target: nil, action: nil)) }
        scheduler.scheduleAt(110) { searchBarTouchSubject.dispose() }
        scheduler.start()
        
        XCTAssertEqual(observerMoveSearchBarSubject.events, [
            .next(10,true),
            .next(100,true)])

    }
    
    
}
