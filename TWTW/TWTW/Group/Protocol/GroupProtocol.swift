//
//  GroupProtocol.swift
//  TWTW
//
//  Created by 정호진 on 11/28/23.
//

import Foundation
import RxSwift

protocol GroupProtocol {
    /// 자신이 속한 그룹 받기
    /// - Returns: 자신이 속한 그룹
    func groupList() -> Observable<[Group]>
}
