//
//  SurroundSearchProtocol.swift
//  TWTW
//
//  Created by 정호진 on 11/23/23.
//

import Foundation
import RxSwift

protocol SurroundSearchProtocol {
    /// 검색어와 카테고리를 통한 장소 검색
    func surroundSearchPlaces(xPosition: Double,
                              yPosition: Double,
                              page: Int,
                              categoryGroupCode: String) -> Observable<SurroundSearchPlaces>
}
