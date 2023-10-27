//
//  SearchPlacesMapViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/13.
//

import Foundation
import UIKit
import RxRelay
import CoreLocation
import Alamofire
import RxSwift

final class SearchPlacesMapViewModel {
    
    weak var coordinator: SearchPlacesMapCoordinatorProtocol?
    private let disposeBag = DisposeBag()
    private let searchPlacesServices: SearchPlaceProtocol?
    let selectedCoordinate = PublishRelay<CLLocationCoordinate2D>()
    
    struct Input{
        let searchText: BehaviorRelay<String>
    }
    
    struct Output{
        let filteredPlaces: BehaviorRelay<[Place]> = BehaviorRelay<[Place]>(value: [])
        let selectedCoordinate: PublishRelay<CLLocationCoordinate2D> = PublishRelay<CLLocationCoordinate2D>()
    }
    
    init(coordinator: SearchPlacesMapCoordinatorProtocol?, searchPlacesServices : SearchPlaceProtocol?) {
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
            .flatMapLatest { searchText in
                let request = PlacesRequest(query: searchText)
                
                return self.searchPlacesServices?.searchPlaceService(request: request) ?? .just(PlaceResponse(placeInfo: []))
            }
            .map { placeResponse in
                return placeResponse.placeInfo
            }
            .bind(to: output.filteredPlaces)
            .disposed(by: disposeBag)
        return output
    }
    
}
