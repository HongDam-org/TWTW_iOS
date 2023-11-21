//
//  SearchPlaceMapViewModelUnitTests.swift
//  TWTWUnitTests
//
//  Created by 박다미 on 2023/11/21.
//
import XCTest
import RxSwift
import RxTest
import RxCocoa

@testable import TWTW

final class SearchPlacesMapViewModelUnitTests: XCTestCase {
    
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    private var viewModel: SearchPlacesMapViewModel!
    private var mockService: MockSearchPlacesMapService!
    private var input: SearchPlacesMapViewModel.Input!
    private var output: SearchPlacesMapViewModel.Output!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        scheduler = TestScheduler(initialClock: 0)
        mockService = MockSearchPlacesMapService()
        viewModel = SearchPlacesMapViewModel(coordinator: nil, searchPlacesServices: mockService)
        disposeBag = DisposeBag()
    }
    
    override func tearDownWithError() throws {
        disposeBag = nil
        scheduler = nil
        viewModel = nil
        try super.tearDownWithError()
    }
    func testLoadDataOnSearchTextChange() {
        // Mock response 설정
        let mockPlaces =
        [SearchPlace(placeName: "Place1", distance: "100m", placeURL: "url", categoryName: "Cafe",
                     addressName: "Address", roadAddressName: "Road Address", categoryGroupCode: "CGC", xPosition: "100.0", yPosition: "200.0")]
        mockService.mockResponse = PlaceResponse(results: mockPlaces, isLast: false)
        
        let searchTextObservable = scheduler.createHotObservable([
            .next(10, "test query")
        ]).asObservable().map { $0 as String? }
        
        input = SearchPlacesMapViewModel.Input(
            searchText: searchTextObservable,
            loadMoreTrigger: PublishRelay<Void>(),
            selectedCoorinate: Observable<SearchPlace>.never()
        )
        
        output = viewModel.bind(input: input)
        
        let result = scheduler.createObserver([SearchPlace].self)
        output.filteredPlaces.bind(to: result).disposed(by: disposeBag)
        
        scheduler.start()
       
        XCTAssertEqual(result.events.count, 2)
        //           if let firstEvent = result.events.first {
        //               //XCTAssertEqual(firstEvent.time, 10)
        //              // XCTAssertNotNil(firstEvent.value.element)
        //           }
    }
    func testSelectingPlaceCallsCoordinator() {
        // Mock response
        let selectedPlace =
        SearchPlace(placeName: "Place1", distance: "100m", placeURL: "url", categoryName: "Cafe",
                    addressName: "Address", roadAddressName: "Road Address", categoryGroupCode: "CGC", xPosition: "100.0", yPosition: "200.0")
        let selectedPlaceObservable = scheduler.createHotObservable([
            .next(15, selectedPlace)
        ]).asObservable()
        input = SearchPlacesMapViewModel.Input(
            searchText: Observable.just("test query"),
            loadMoreTrigger: PublishRelay<Void>(),
            selectedCoorinate: selectedPlaceObservable
        )
        output = viewModel.bind(input: input)
        scheduler.start()
        
        // MockSearchPlacesMapCoordinator, finishSearchPlaces 호출 여부
        // XCTAssertTrue(mockCoordinator.finishSearchPlacesCalled)
    }
}
