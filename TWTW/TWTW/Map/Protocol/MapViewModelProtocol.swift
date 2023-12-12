//
//  MapViewModelProtocol.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/12.
//

import Foundation

protocol MapViewModelProtocol {
    var viewModelType: String { get }
    var output: MainMapViewModel.Output? { get set }
}
