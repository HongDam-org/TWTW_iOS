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

    private let mockPlace1 = SearchPlace(placeName: "Place1", distance: "100m", placeURL: "url",
                                         categoryName: "Cafe", addressName: "Address", roadAddressName: "RoadAdd",
                                         categoryGroupCode: "CGC", xPosition: "100.0", yPosition: "200.0")
    private let mockPlace2 = SearchPlace(placeName: "Place2", distance: "200m", placeURL: "url2",
                                         categoryName: "Cafe2", addressName: "Address2", roadAddressName: "RoadAdd2",
                                         categoryGroupCode: "CGC2", xPosition: "300.0", yPosition: "400.0")

    override func setUpWithError() throws {
        try super.setUpWithError()
        scheduler = TestScheduler(initialClock: 0)
        mockCoordinator = MockSearchPlacesMapCoordinator(childCoordinators: [], navigationController: UINavigationController())
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
        mockService.mockResponse = PlaceResponse(results: [mockPlace1], isLast: false)

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

        if let resultAt10 = result.events.filter({ $0.time == 10 })
            .first?.value.element?.first {
            XCTAssertEqual(resultAt10.placeName, mockPlace1.placeName, "time 10에 place1결과")
        } else {
            XCTFail("결과없음")
        }
    }

    // Place1 Place2 표시되는지, 장소들을 선택했을 때  xPosition과 yPosition이 반환
    func testTableViewCellSelectsCorrectCoordinates() {
        mockService.mockResponse = PlaceResponse(results: [mockPlace1, mockPlace2], isLast: false)
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
        let resultsAt10 = result.events.filter { $0.time == 10 }.first?.value.element ?? []
        XCTAssertEqual(resultsAt10.map { $0.placeName }, ["Place1", "Place2"], "time 10에 Place1과 Place2 표시")

        let selectedPlaceObservable = scheduler.createHotObservable([
            .next(20, mockPlace1),
            .next(30, mockPlace2)
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
        mockService.mockResponse = PlaceResponse(results: [mockPlace1], isLast: false)

        let searchTextObservable = scheduler.createHotObservable([
            .next(10, "Place1")
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
            self.mockService.mockResponse = PlaceResponse(results: [self.mockPlace2], isLast: false)
            loadMoreTrigger.accept(())
        }

        scheduler.start()

        let resultsAt15 = result.events.filter { $0.time == 15 }.first?.value.element ?? []
           let placeNamesAt15 = resultsAt15.map { $0.placeName }
        XCTAssertEqual(placeNamesAt15, [mockPlace1.placeName, mockPlace2.placeName], "time 15에 추가된결과 Place1 Place2")
    }
}
