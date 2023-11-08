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
    let selectedCoordinate = PublishRelay<CLLocationCoordinate2D>()
    
    struct Input {
        let searchText: BehaviorRelay<String>
    }
    
    struct Output {
        let filteredPlaces: BehaviorRelay<[SearchPlace]> = BehaviorRelay<[SearchPlace]>(value: [])
        
        let selectedCoordinate: PublishRelay<CLLocationCoordinate2D> = PublishRelay<CLLocationCoordinate2D>()
    }
    
    init(coordinator: SearchPlacesMapCoordinatorProtocol?, searchPlacesServices: SearchPlaceProtocol?) {
        self.coordinator = coordinator
        self.searchPlacesServices = searchPlacesServices
    }
    
    func bind(input: Input) -> Output {
        return createOutput(input: input)
    }
    
    private func createOutput(input: Input) -> Output {
        let output = Output()
        
        input.searchText
            .distinctUntilChanged()
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .flatMapLatest { [weak self] searchText in
                self?.searchPlacesServices?
                    .searchPlaceService(request: PlacesRequest(searchText: searchText)) ?? .just(PlaceResponse(results: [], isLast: false))
            }
            .bind { placeResponse in
                var list = output.filteredPlaces.value
                list.append(contentsOf: placeResponse.results)
                output.filteredPlaces.accept(list)
            }
            .disposed(by: disposeBag)
        return output
    }
    
}
