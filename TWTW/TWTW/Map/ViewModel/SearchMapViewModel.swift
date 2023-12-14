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
    // var output: MainMapViewModel.Output?
    private let coordinator: DefaultMainMapCoordinator?
    private let disposeBag = DisposeBag()

    struct Input {
        let searchBarTouchEvents: Observable<ControlEvent<UITapGestureRecognizer>.Element>?
    }
    struct Output {
        var moveSearchCoordinator: PublishSubject<Bool> = PublishSubject()
    }
    // MARK: - init
    init(coordinator: DefaultMainMapCoordinator?) {
        self.coordinator = coordinator
    }

    /// bind
    func bind(input: Input) -> Output {
        return createOutput(input: input)
    }
    /// create output
    private func createOutput(input: Input) -> Output {
        let output = Output()
        input.searchBarTouchEvents?
            .bind { [weak self] _ in
                guard let self = self else {return}
                output.moveSearchCoordinator.onNext(true)
                moveSearch(output: output)
            }
            .disposed(by: disposeBag)
        return output
    }
    
    private func moveSearch(output: Output) {
       // coordinator?.moveSearch(output: output)
    }
}
