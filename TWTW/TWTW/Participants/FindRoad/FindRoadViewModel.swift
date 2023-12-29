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
        let pedRouteButtonTap: Observable<Void>
    }
    
    struct Output {
        var destinationCarPathRelay: BehaviorRelay<[[Double]]> = BehaviorRelay(value: [[]])
        var destinationPedPathRelay: BehaviorRelay<[Feature]> = BehaviorRelay(value: [])
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
                let endCoordinate = "127.075986,37.179470"
                let body = CarRouteRequest(start: startCoordinate,
                                           end: endCoordinate,
                                           way: "",
                                           option: "TRAFAST",
                                           fuel: "DIESEL",
                                           car: 1)
                getCarRoute(body: body, output: output)
            })
            .disposed(by: disposeBag)
        
        input.pedRouteButtonTap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                // 보행자 경로 요청 시 사용할 파라미터 설정
                // 시작점과 도착점의 위도와 경도를 Double 타입으로 변환
                let startLatitude = 37.3977149815
                let startLongitude = 126.73570807
                let endLatitude = 37.179470
                let endLongitude = 127.075986
                
                let body = PedRouteRequest(startX: startLongitude,
                                           startY: startLatitude,
                                           endX: endLongitude,
                                           endY: endLatitude,
                                           startName: "Start Point",
                                           endName: "End Point")
                self.getPedRoute(body: body, output: output)
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
    
    /// 보도 경로 가져오기
    private func getPedRoute(body: PedRouteRequest, output: Output) {
        routeService?.pedRoute(request: body)
            .subscribe(onNext: { route in
                output.destinationPedPathRelay.accept(route.features)
            }, onError: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
    
}
