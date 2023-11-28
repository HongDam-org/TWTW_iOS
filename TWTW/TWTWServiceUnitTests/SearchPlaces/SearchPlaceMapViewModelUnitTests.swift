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
import CoreLocation

@testable import TWTW

final class SearchPlacesMapViewModelUnitTests: XCTestCase {
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    private var viewModel: SearchPlacesMapViewModel!
    private var mockService: MockSearchPlacesMapService!
    private var input: SearchPlacesMapViewModel.Input!
    private var output: SearchPlacesMapViewModel.Output!
    private var mockCoordinator: MockSearchPlacesMapCoordinator!

    override func setUpWithError() throws {
        try super.setUpWithError()
        scheduler = TestScheduler(initialClock: 0)
        mockCoordinator = MockSearchPlacesMapCoordinator(childCoordinators: [],
                                                         navigationController: UINavigationController())
        mockService = MockSearchPlacesMapService()
        viewModel = SearchPlacesMapViewModel(coordinator: mockCoordinator, searchPlacesServices: mockService)
        disposeBag = DisposeBag()
    }
    override func tearDownWithError() throws {
        disposeBag = nil
        scheduler = nil
        viewModel = nil
        mockCoordinator = nil
        try super.tearDownWithError()
    }

    func testLoadDataOnSearchTextChange() {
        let searchTextObservable = scheduler.createHotObservable([
            .next(10, "Place1")
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

        if let resultAt10 = result.events.filter({ $0.time == 10 }).first?.value.element?.first {
            XCTAssertEqual(resultAt10.placeName, mockService.mockPlace1.placeName, "PlaceName 일치")
            XCTAssertEqual(resultAt10.distance, mockService.mockPlace1.distance, "Distance 일치")
        } else {
            XCTFail("결과없음")
        }
    }

    // 클릭시 xPosition과 yPosition이 반환
    func testTableViewCellSelectsCorrectCoordinates() {
        let searchTextObservable = scheduler.createHotObservable([
            .next(10, "Place")
        ]).asObservable().map { $0 as String? }

        let selectedPlaceObservable = scheduler.createHotObservable([
            .next(20, mockService.mockPlace1),
            .next(30, mockService.mockPlace2)
        ]).asObservable()

        input = SearchPlacesMapViewModel.Input(
            searchText: searchTextObservable,
            loadMoreTrigger: PublishRelay<Void>(),
            selectedCoorinate: selectedPlaceObservable
        )

        output = viewModel.bind(input: input)

        let selectedPlaceResult = scheduler.createObserver(CLLocationCoordinate2D.self)
        selectedPlaceObservable.map { CLLocationCoordinate2D(latitude: Double($0.yPosition) ?? 0,
                                                             longitude: Double($0.xPosition) ?? 0) }
        .bind(to: selectedPlaceResult)
        .disposed(by: disposeBag)

        scheduler.start()
        let expectedCoordinate1 = CLLocationCoordinate2D(latitude: 200.0, longitude: 100.0)
        let expectedCoordinate2 = CLLocationCoordinate2D(latitude: 400.0, longitude: 300.0)
        let actualCoordinates = selectedPlaceResult.events.compactMap { $0.value.element }

        if let firstCoordinate = actualCoordinates.first {
            XCTAssertTrue(firstCoordinate.latitude == expectedCoordinate1.latitude &&
                          firstCoordinate.longitude == expectedCoordinate1.longitude, "첫 번째 장소 좌표")
        } else {
            XCTFail("첫 번째 장소 좌표가 반환되지 않음")
        }

        if actualCoordinates.count > 1 {
            let secondCoordinate = actualCoordinates[1]
            XCTAssertTrue(secondCoordinate.latitude == expectedCoordinate2.latitude &&
                          secondCoordinate.longitude == expectedCoordinate2.longitude, "두 번째 장소 좌표 ")
        } else {
            XCTFail("두 번째 장소 좌표가 반환되지 않음")
        }
        selectedPlaceObservable.subscribe(onNext: { [weak self] place in
            let coordinate = CLLocationCoordinate2D(
                latitude: Double(place.yPosition) ?? 0,
                longitude: Double(place.xPosition) ?? 0)
            self?.mockCoordinator.finishSearchPlaces(coordinate: coordinate)
        }).disposed(by: disposeBag)
        XCTAssertTrue(mockCoordinator.finishSearchPlacesCalled, "finishSearchPlaces")
    }

    func testLoadMoreSearchResults() {
        let searchTextObservable = scheduler.createHotObservable([
            .next(10, "Place")
        ]).asObservable().map { $0 as String? }

        let loadMoreTrigger = PublishRelay<Void>()
        input = SearchPlacesMapViewModel.Input(
            searchText: searchTextObservable,
            loadMoreTrigger: loadMoreTrigger,
            selectedCoorinate: Observable<SearchPlace>.never()
        )

        output = viewModel.bind(input: input)
        let result = scheduler.createObserver([SearchPlace].self)
        output.filteredPlaces.bind(to: result).disposed(by: disposeBag)

        scheduler.scheduleAt(15) {
            loadMoreTrigger.accept(())
        }

        scheduler.start()

        let resultsAt15 = result.events.filter { $0.time >= 15 }.compactMap { $0.value.element }.flatMap { $0 }
        let placeNamesAt15 = resultsAt15.map { $0.placeName }

        XCTAssertEqual(placeNamesAt15, ["Place1", "Place2"],
                       "time 15에 추가된결과 Place1 Place2")
    }
}
