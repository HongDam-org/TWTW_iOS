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

/// 서치 ViewModel:  SearchPlacesMapViewModel
final class SearchPlacesMapViewModel {
    weak var coordinator: SearchPlacesMapCoordinatorProtocol?
    private let disposeBag = DisposeBag()
    private let searchPlacesServices: SearchPlaceProtocol?
    private let surroundSearchServices: SurroundSearchProtocol?
    private var state = SearchPlacesMapState()
    private let caller: StartCaller
    struct Input {
        /// searchbar 글자변경 감지
        let searchText: Observable<String?>
        
        /// 테이블 뷰 마지막 감지시 추가 로드
        let loadMoreTrigger: PublishRelay<Void>
        
        /// 장소 테이블 선택 감지
        let selectedPlace: Observable<SearchPlace>
    }
    
    struct Output {
        /// 테이블뷰에 보낼 검색장소
        let filteredPlaces: BehaviorRelay<[SearchPlace]> = BehaviorRelay<[SearchPlace]>(value: [])
        
        /// 서버에 보낼 Url text
        let searchText: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    }
    
    // MARK: - init
    init(coordinator: SearchPlacesMapCoordinatorProtocol?,
         searchPlacesServices: SearchPlaceProtocol?,
         surroundSearchServices: SurroundSearchProtocol?,
         caller: StartCaller = .defaults) {
        self.coordinator = coordinator
        self.searchPlacesServices = searchPlacesServices
        self.surroundSearchServices = surroundSearchServices
        self.caller = caller
    }
    
    ///  bind
    func bind(input: Input) -> Output {
        let output = createOutput(input: input)
        return output
    }
    
    /// createOutput
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
        
        /// 트리거로 추가 데이터를 로드하고 VC에 전달
        input.loadMoreTrigger
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                loadMoreData(output: output)
            })
            .disposed(by: disposeBag)

        
        input.selectedPlace
            .bind(onNext: { [weak self] selectedPlace in
                guard let self = self else { return }
                switch self.caller {
                case .forStartCaller:
                    print("내위치 선택")
                case .defaults:
                    // 장소 이름 저장
                    if let placeName = selectedPlace.placeName {
                        _ = KeychainWrapper.saveItem(value: placeName, forKey: SearchPlaceKeyChain.placeName.rawValue)
                    }
                    
                    // 장소 URL 저장
                    if let placeURL = selectedPlace.placeURL {
                        _ = KeychainWrapper.saveItem(value: placeURL, forKey: SearchPlaceKeyChain.placeURL.rawValue)
                    }
                    
                    // 도로명 주소 저장
                    if let roadAddressName = selectedPlace.roadAddressName {
                        _ = KeychainWrapper.saveItem(value: roadAddressName, forKey: SearchPlaceKeyChain.roadAddressName.rawValue)
                    }
                    
                    // 경도 저장
                    if let longitude = selectedPlace.longitude {
                        _ = KeychainWrapper.saveItem(value: "\(longitude)", forKey: SearchPlaceKeyChain.longitude.rawValue)
                    }
                    
                    // 위도 저장
                    if let latitude = selectedPlace.latitude {
                        _ = KeychainWrapper.saveItem(value: "\(latitude)", forKey: SearchPlaceKeyChain.latitude.rawValue)
                    }
                    self.coordinator?.finishSearchPlaces()
                case .groupMemberList:
                    // 경도 저장
                    if let longitude = selectedPlace.longitude {
                        _ = KeychainWrapper.saveItem(value: "\(longitude)", forKey: SearchPlaceKeyChain.longitude.rawValue)
                    }
                    
                    // 위도 저장
                    if let latitude = selectedPlace.latitude {
                        _ = KeychainWrapper.saveItem(value: "\(latitude)", forKey: SearchPlaceKeyChain.latitude.rawValue)
                    }
                    self.coordinator?.finishSearchPlaces()
                }
            })
            .disposed(by: disposeBag)
        
        return output
    }

    /// 데이터 로드
    private func loadData(output: Output) {
        state.pageNum = 1
        searchPlacesServices?.searchPlaceService(request: PlacesRequest(searchText: output.searchText.value,
                                                                        pageNum: state.pageNum))
        .subscribe(onNext: { [weak self] placeResponse in
            self?.state.isLastPage = placeResponse.isLast ?? false
            output.filteredPlaces.accept(placeResponse.results)
        })
        .disposed(by: disposeBag)
    }
    
    /// 추가 데이터 로드
    private func loadMoreData(output: Output) {
        guard !state.isLastPage else { return }
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
