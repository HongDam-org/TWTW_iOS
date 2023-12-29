//
//  FindRoadViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/18.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit

final class FindRoadViewModel {
    private let disposeBag = DisposeBag()
    private let routeService: RouteProtocol?
    weak var coordinator: DefaultsFindRoadCoordinator?
    
    struct Input {
        let myLocationTap: Observable<Void>
        let carRouteButtonTap: Observable<Void>
    }
    struct Output {
        /// 목적지 까지의 경로
        var destinationCarPathRelay: BehaviorRelay<[[Double]]> = BehaviorRelay(value: [[]])
    }

    // MARK: - Init
    init(coordinator: DefaultsFindRoadCoordinator?, routeService: RouteProtocol) {
        self.coordinator = coordinator
        self.routeService = routeService
    }
    /// bind
    func bind(input: Input) -> Output {
        return createOutput(input: input)
    }
    /// create output
    private func createOutput(input: Input) -> Output {
        let output = Output()
    
        input.myLocationTap
            .subscribe(onNext: {[weak self] in
                guard let self = self else { return }
                coordinator?.moveToStartSearchPlace()
            })
            .disposed(by: disposeBag)
        input.carRouteButtonTap
                    .subscribe(onNext: { [weak self] in
                        guard let self = self else { return }
                        
                        let startCoordinate = "126.73570807,37.3977149815"
                        let endCoordinate = "129.075986,35.179470"
                        let body = CarRouteRequest(start: startCoordinate,
                                                   end: endCoordinate,
                                                   way: "",
                                                   option: "TRAFAST",
                                                   fuel: "DIESEL",
                                                   car: 1)
                        getCarRoute(body: body, output: output)
                    })
                    .disposed(by: disposeBag)
        return output
    }
    /// 자동차 경로 가져오기
    private func getCarRoute(body: CarRouteRequest, output: Output) {
        routeService?.carRoute(request: body)
            .subscribe(onNext: { route in
                output.destinationCarPathRelay.accept(route.route?.trafast?.first?.path ?? [])
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
}
