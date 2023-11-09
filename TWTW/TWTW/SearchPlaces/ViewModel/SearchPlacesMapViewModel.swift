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
    
    // 현재 페이지 번호와 검색 텍스트를 저장할 변수 추가
    private var pageNum: Int = 1
    private var currentSearchText: String = ""
    
    struct Input {
        let searchText: BehaviorRelay<String>
        let loadMoreTrigger: PublishRelay<Void>
        let selectedCoorinate: Observable<SearchPlace>
    }
    
    struct Output {
        let filteredPlaces: BehaviorRelay<[SearchPlace]> = BehaviorRelay<[SearchPlace]>(value: [])
        
        let selectedCoordinate: PublishRelay<CLLocationCoordinate2D> = PublishRelay<CLLocationCoordinate2D>()
        
        let loaindNextData: BehaviorRelay<[SearchPlace]> = BehaviorRelay<[SearchPlace]>(value: [])
    }
    
    init(coordinator: SearchPlacesMapCoordinatorProtocol?, searchPlacesServices: SearchPlaceProtocol?) {
        self.coordinator = coordinator
        self.searchPlacesServices = searchPlacesServices
    }
    
    func bind(input: Input) -> Output {
        let output = createOutput(input: input)
        
        // 검색 텍스트 변경에 따라 페이지 번호를 초기화하고 새로운 데이터를 가져옴
        input.searchText
            .distinctUntilChanged()
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] searchText in
                guard let self = self else { return }
                pageNum = 1
                currentSearchText = searchText
                loadData(output: output)
            })
            .disposed(by: disposeBag)
        
        // 추가 데이터를 로드하는 트리거를 감시
        input.loadMoreTrigger
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                loadMoreData(output: output)
            })
            .disposed(by: disposeBag)
        
        input.selectedCoorinate
            .bind(onNext: { [weak self] selectedPlace in
                guard let self = self,
                      let placeX = Double(selectedPlace.xPosition),
                      let placeY = Double(selectedPlace.yPosition) else { return }
                let coordinate = CLLocationCoordinate2D(latitude: placeY, longitude: placeX)
                output.selectedCoordinate.accept(coordinate)
                coordinator?.finishSearchPlaces(coordinate: coordinate)
            })
            .disposed(by: disposeBag)
        
        return output
    }
    
    private func createOutput(input: Input) -> Output {
        let output = Output()
        
        input.searchText
            .distinctUntilChanged()
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] searchText in
                self?.pageNum = 1 // 검색 텍스트가 변경될 때 pageNum을 1로 리셋
                self?.currentSearchText = searchText
                self?.searchPlacesServices?.searchPlaceService(request: PlacesRequest(searchText: searchText, pageNum: 1))
                    .subscribe(onNext: { placeResponse in
                        output.filteredPlaces.accept(placeResponse.results) // 새 데이터로 교체
                    })
                    .disposed(by: self?.disposeBag ?? DisposeBag())
            })
            .disposed(by: disposeBag)
        
        // 트리거로 추가 데이터를 로드하고 VC에 전달
        input.loadMoreTrigger
            .subscribe(onNext: { [weak self] in
                self?.loadMoreData(output: output)
            })
            .disposed(by: disposeBag)
        return output
    }
    
    // 데이터 로드
    private func loadData(output: Output) {
        searchPlacesServices?.searchPlaceService(request: PlacesRequest(searchText: currentSearchText, pageNum: 1))
            .subscribe(onNext: { placeResponse in
                output.filteredPlaces.accept(placeResponse.results)
            })
            .disposed(by: disposeBag)
    }
    
    // 추가 데이터 로드
    private func loadMoreData(output: Output) {
        pageNum += 1 // 페이지 번호 증가
        searchPlacesServices?.searchPlaceService(request: PlacesRequest(searchText: currentSearchText, pageNum: pageNum))
            .subscribe(onNext: { placeResponse in
                output.loaindNextData.accept(placeResponse.results)
            })
            .disposed(by: disposeBag)
    }
}
