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
        let nowViewHeight: Observable<CGFloat>
    }
    
    struct Output {
        var heightRelay: BehaviorRelay<CGFloat> = BehaviorRelay(value: CGFloat())
        
    }
    
    /// transform Input to Output
    /// - Parameter input: Input
    /// - Returns: Output
    func transform(input: Input, baseViewHeight: CGFloat) -> Output {
        
        return createOutput(input: input, baseViewHeight: baseViewHeight)
    }
    
    /// MARK: create output
    /// - Parameter input: Input Observable
    /// - Returns: Output
    private func createOutput(input: Input, baseViewHeight: CGFloat) -> Output {
        let output = Output()
    
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
                
                case .began:
                    print("began")
                    
                case .changed:
                    print("changed")
                    // 뷰의 현재 높이와 이동된 간격을 기반으로 새로운 높이를 계산
                    let transition = gesture.translation(in: gesture.view)
                    print("transition\(transition)")
                    // 최소 높이와 최대 높이를 벗어나지 않도록 보정
                    
                    let heightByTouch = min(max((gesture.view?.frame.height ?? 0) - transition.y, baseViewHeight * 0.15), baseViewHeight * 0.8 * (1 + 0.1))
                    
                    gesture.view?.frame.origin.y += transition.y
                    gesture.view?.frame.size.height -= transition.y
//                    gesture.view?.frame.size.height = heightByTouch
                    output.heightRelay.accept(gesture.view?.frame.height ?? 0)
                    gesture.setTranslation(.zero, in: gesture.view)
                    
                    gesture.velocity(in: gesture.view).y < 0 ? print("상 \(gesture.velocity(in: gesture.view))") : print("하 \(gesture.velocity(in: gesture.view))")
                    
                case .ended, .possible:
                    print("ended")
                    print(gesture.translation(in: gesture.view).y)
                    
                    let targetHeight = calculateHeightWhenScrollUp(changedHeight: viewHeight, viewHeight: baseViewHeight)
                    //  ViewModel을 사용하여 최종 높이를 계산
                    let finalHeight = calculateHeightWhenScrollUp(changedHeight: targetHeight, viewHeight: baseViewHeight)
                    output.heightRelay.accept(finalHeight)
                    return
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        }
        
        return output
    }
    
    // 최종 높이 계산
    private func calculateHeightWhenScrollUp(changedHeight: CGFloat, viewHeight: CGFloat) -> CGFloat {
        if changedHeight > viewHeight * 0.4 {
            return viewHeight * 0.8
        }
        else if changedHeight > viewHeight * 0.15 {
            return viewHeight * 0.4
        }
        return viewHeight * 0.15
    }
    
    // 최종 높이 계산
    private func calculateHeightWhenScrollDown(changedHeight: CGFloat, viewHeight: CGFloat) -> CGFloat {
        if changedHeight > viewHeight * 0.35{
            return viewHeight * 0.4
        }
        if changedHeight > viewHeight * 0.1 {
            return viewHeight * 0.15
        }
        return viewHeight * 0.8
    }
}


