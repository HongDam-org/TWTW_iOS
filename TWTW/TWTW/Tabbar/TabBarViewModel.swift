//
//  TabBarViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/09/10.
//

import Foundation
import RxSwift
import RxCocoa
import SnapKit
import RxGesture
import UIKit

///TabBarViewModel
final class TabBarViewModel {
    private let disposeBag = DisposeBag()
    
    struct Input {
        let homePanEvents: Observable<ControlEvent<UIPanGestureRecognizer>.Element>?
        let schedulePanEvents: Observable<ControlEvent<UIPanGestureRecognizer>.Element>?
        let friendsListPanEvents: Observable<ControlEvent<UIPanGestureRecognizer>.Element>?
        let notificationPanEvents: Observable<ControlEvent<UIPanGestureRecognizer>.Element>?
        let callPanEvents: Observable<ControlEvent<UIPanGestureRecognizer>.Element>?
        let nowViewHeight: BehaviorSubject<CGFloat>
        let viewHeight: CGFloat
    }
    
    struct Output {
        var heightRelay: BehaviorRelay<CGFloat> = BehaviorRelay(value: CGFloat())
        
    }
    
    /// transform Input to Output
    /// - Parameter input: Input
    /// - Returns: Output
    func transform(input: Input) -> Output {
        
        return createOutput(input: input)
    }
    
    /// MARK: create output
    /// - Parameter input: Input Observable
    /// - Returns: Output
    private func createOutput(input: Input) -> Output {
        let output = Output()
        
        input.nowViewHeight.bind{ height in
            output.heightRelay.accept(height*0.3)
        }.disposed(by: disposeBag)
        
        if let homePanEvents = input.homePanEvents,
           let schedulePanEvents = input.schedulePanEvents,
           let friendsListPanEvents = input.friendsListPanEvents,
           let notificationPanEvents = input.notificationPanEvents,
           let callPanEvents = input.callPanEvents {
            
            Observable.combineLatest(Observable.merge(homePanEvents,
                                                      schedulePanEvents,
                                                      friendsListPanEvents,
                                                      notificationPanEvents,
                                                      callPanEvents),
                                     input.nowViewHeight)
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] gesture, viewHeight in
                guard let self = self else {return}
                
                switch gesture.state {
                case .changed:
                    print("changed")
                    let gapTouchY = gesture.translation(in: gesture.view).y
                    // 뷰의 현재 높이와 이동된 간격을 기반으로 새로운 높이를 계산
                    var heightByTouch = viewHeight - gapTouchY
//                    print("viewHeight: \(viewHeight), gap: \(gapTouchY), before heightByTouch: \(heightByTouch)")
                    // 최소 높이와 최대 높이를 벗어나지 않도록 보정
                    heightByTouch = min(max(heightByTouch, input.viewHeight * 0.15), input.viewHeight * 0.8 * (1 + 0.1))
//                    print("gap: \(gapTouchY), after heightByTouch: \(heightByTouch)")
                    input.nowViewHeight.onNext(heightByTouch)
                    output.heightRelay.accept(heightByTouch)
                    
                case .ended:
                    print("ended")
                    let targetHeight = calculateFinalHeight(changedHeight: viewHeight, input: input, viewHeight: input.viewHeight)
                    //  ViewModel을 사용하여 최종 높이를 계산
                    let finalHeight = calculateFinalHeight(changedHeight: targetHeight, input: input, viewHeight: input.viewHeight)
                    input.nowViewHeight.onNext(finalHeight)
                    output.heightRelay.accept(finalHeight)
                default:
                    return
                }
            }
            .disposed(by: disposeBag)
        }
        
        return output
    }
    
    // 최종 높이 계산
    func calculateFinalHeight(changedHeight: CGFloat, input: Input, viewHeight: CGFloat) -> CGFloat {
        if changedHeight > viewHeight * 0.5 {
            return viewHeight * 0.8
        }
        else if changedHeight > viewHeight * 0.3 {
            return viewHeight * 0.5
        }
        else if changedHeight > viewHeight * 0.15 {
            return viewHeight * 0.3
        }
        return viewHeight * 0.15
    }
}


