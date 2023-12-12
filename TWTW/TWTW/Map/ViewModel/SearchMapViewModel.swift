//
//  SearchMapViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/11.
//

import CoreLocation
import Foundation
import KakaoMapsSDK
import RxCocoa
import RxGesture
import RxRelay
import RxSwift
import UIKit

/// SearchMapViewModel
final class SearchMapViewModel: MapViewModelProtocol {
    var viewModelType = "SearchMapViewModel"
    var output: MainMapViewModel.Output?
}
