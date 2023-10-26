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
    var selectedCoordinateSubject = PublishRelay<CLLocationCoordinate2D>()
    var filteredPlaces: PublishRelay<[Place]> = PublishRelay()
    private let disposeBag = DisposeBag()
    
    struct Input{
        let searchText: BehaviorRelay<String>
    }
    struct Output{
        let filteredPlaces: BehaviorRelay<[Place]>
    }
    var input: Input
    var output: Output
    
    //    func bind(input: Input) ->Output {
    //        return createOutput(input: input)
    //    }
    //
    
    init() {
        // (Input)과 (Output)을 초기화
        let searchText = BehaviorRelay<String>(value: "")
        let filteredPlaces = BehaviorRelay<[Place]>(value: [])
        
        input = Input(searchText: searchText)
        output = Output(filteredPlaces: filteredPlaces)
        
        // searchText의 변화를 구독하고 filteredPlaces를 업데이트
        searchText
            .distinctUntilChanged()
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                // Service에서 데이터를 비동기로 가져와서 업데이트
                SearchPlacesMapService.checkSearchPlaceAccess(searchText: text) { places, error in
                    if let places = places {
                        // Service에서 가져온 데이터로 filteredPlaces 배열을 업데이트
                        self?.output.filteredPlaces.accept(places)
                    } else if let error = error {
                        print(error)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    ///선택한 좌표로 coordinator로 전달
    func selectLocation(xCoordinate: Double, yCoordinate: Double) {
        selectedCoordinateSubject.accept(CLLocationCoordinate2D(latitude: yCoordinate, longitude: xCoordinate))
    }
}
