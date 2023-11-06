//
//  SearchPlacesMapCoordinator.swift
//  TWTW
//
//  Created by 박다미 on 2023/10/13.
//

import Foundation
import UIKit
import RxSwift

protocol SearchPlacesMapCoordinatorProtocol:Coordinator {
    //장소검색 이후
    func finishSearchPlaces()
}
