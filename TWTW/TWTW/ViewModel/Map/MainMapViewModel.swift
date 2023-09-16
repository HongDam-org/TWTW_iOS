//
//  MainMapViewModel.swift
//  TWTW
//
//  Created by 정호진 on 2023/08/12.
//

import Foundation
import RxSwift
import RxRelay

final class MainMapViewModel: NSObject {
    
    /// 지도 화면 터치 감지 Relay
    ///  true: UI 제거하기, false: UI 표시
    var checkTouchEventRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    /// MARK: 내위치 선택했을 때
    let myLocationTappedSubject = PublishRelay<Void>()
    
    /// MARK: 검색지 주변 장소 데이터
    var placeData: BehaviorRelay<[SearchNearByPlaces]> = BehaviorRelay(value: [])
    
    /// 서치바 동작기능 변형 버튼기능 -> 검색기능
    var searchBarSearchable : BehaviorRelay<Bool> = BehaviorRelay(value: true)
    
    // MARK: - Logic
    
    /// MARK: checking Touch Events
    func checkingTouchEvents() {
        let check = checkTouchEventRelay.value
        checkTouchEventRelay.accept(!check)
    }
    
    /// MARK: 검색지 주변 장소 더미 데이터
    func searchInputData_Dummy(){
        var list = placeData.value
        
        list.append(SearchNearByPlaces(imageName: "image", title: "Place 1", subTitle: "detail aboudPlace 1"))
        list.append(SearchNearByPlaces(imageName: "image", title: "Place 2", subTitle: "detail aboudPlace 2"))
        list.append(SearchNearByPlaces(imageName: "image", title: "Place 3", subTitle: "detail aboudPlace 3"))
        list.append(SearchNearByPlaces(imageName: "image", title: "Place 4", subTitle: "detail aboudPlace 4"))
        list.append(SearchNearByPlaces(imageName: "image", title: "Place 5", subTitle: "detail aboudPlace 5"))
        list.append(SearchNearByPlaces(imageName: "image", title: "Place 6", subTitle: "detail aboudPlace 6"))
        list.append(SearchNearByPlaces(imageName: "image", title: "Place 7", subTitle: "detail aboudPlace 7"))
        list.append(SearchNearByPlaces(imageName: "image", title: "Place 8", subTitle: "detail aboudPlace 8"))
        placeData.accept(list)
    }
    
    
}

