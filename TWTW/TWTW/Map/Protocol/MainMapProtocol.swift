//
//  MainMapProtocol.swift
//  TWTW
//
//  Created by 정호진 on 1/17/24.
//

import Foundation
import RxSwift

protocol MainMapProtocol {
    func getMyInformation() -> Observable<MyInfo>
    
}
