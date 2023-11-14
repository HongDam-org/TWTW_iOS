//
//  SearchPlacesMapViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/13.
//

import Alamofire
import CoreLocation
import Foundation
import RxRelay
import RxSwift
import UIKit

final class SearchPlacesMapViewModel {
    weak var coordinator: SearchPlacesMapCoordinatorProtocol?
    private let disposeBag = DisposeBag()
    private let searchPlacesServices: SearchPlaceProtocol?
    private var state = SearchPlacesMapState()
    
    struct Input {
        let searchText: Observable<String?>
        let loadMoreTrigger: PublishRelay<Void>
        let selectedCoorinate: Observable<SearchPlace>
    }
    
    struct Output {
        let filteredPlaces: BehaviorRelay<[SearchPlace]> = BehaviorRelay<[SearchPlace]>(value: [])
//        let selectedCoordinate: PublishRelay<CLLocationCoordinate2D> = PublishRelay<CLLocationCoordinate2D>()
        let searchText: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    }
    
    init(coordinator: SearchPlacesMapCoordinatorProtocol?, searchPlacesServices: SearchPlaceProtocol?) {
        self.coordinator = coordinator
        self.searchPlacesServices = searchPlacesServices
    }
    
    func bind(input: Input) -> Output {
        let output = createOutput(input: input)
        return output
    }
    
    private func createOutput(input: Input) -> Output {
        let output = Output()
        
        input.searchText
            .distinctUntilChanged()
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] searchText in
                guard let self = self, let searchText = searchText else {
                    return
                }
                output.searchText.accept(searchText)
                loadData(output: output)
            })
            .disposed(by: disposeBag)
        
        // 트리거로 추가 데이터를 로드하고 VC에 전달
        input.loadMoreTrigger
            .subscribe(onNext: { [weak self] in
                guard let self = self else {
                    return
                }
                loadMoreData(output: output)
            })
            .disposed(by: disposeBag)
        
        input.selectedCoorinate
            .bind(onNext: { [weak self] selectedPlace in
                guard let self = self,
                      let placeX = Double(selectedPlace.xPosition),
                      let placeY = Double(selectedPlace.yPosition) else { return }
                let coordinate = CLLocationCoordinate2D(latitude: placeY, longitude: placeX)
                coordinator?.finishSearchPlaces(coordinate: coordinate)
            })
            .disposed(by: disposeBag)
                
        
        return output
    }
    
    /// 데이터 로드
    private func loadData(output: Output) {
        state.pageNum = 1
        searchPlacesServices?.searchPlaceService(request: PlacesRequest(searchText: output.searchText.value,
                                                                        pageNum: state.pageNum))
            .subscribe(onNext: { placeResponse in
                output.filteredPlaces.accept(placeResponse.results)
            })
            .disposed(by: disposeBag)
    }
    
    /// 추가 데이터 로드
    private func loadMoreData(output: Output) {
        state.pageNum += 1
        searchPlacesServices?.searchPlaceService(request: PlacesRequest(searchText: output.searchText.value,
                                                                        pageNum: state.pageNum))
            .subscribe(onNext: { placeResponse in
                var existingData = output.filteredPlaces.value
                existingData.append(contentsOf: placeResponse.results)
                output.filteredPlaces.accept(existingData)
            })
            .disposed(by: disposeBag)
    }
}
