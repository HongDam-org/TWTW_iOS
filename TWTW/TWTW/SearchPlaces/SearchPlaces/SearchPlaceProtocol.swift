//
//  SearchPlaceProtocol.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/25.
//

import Foundation
import RxSwift

protocol SearchPlaceProtocol{
    ///장소 검색할때 호출
    /// - Parameter request: 서버에 보내는 지역이름정보
    /// - Returns: 지역정보: placeName, 좌표, 주소,...
    func searchPlaceService(request: PlacesRequest) ->
    Observable<PlaceResponse>
}
