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
                case .changed:
                    let transition = gesture.translation(in: gesture.view)
                    
                    gesture.view?.frame.size.height -= transition.y
                    gesture.view?.frame.origin.y += transition.y
                    
                    if gesture.velocity(in: gesture.view).y < 0{
                        let targetHeight = calculateHeightWhenScrollUp(changedHeight: gesture.view?.frame.size.height ?? 0, viewHeight: baseViewHeight)
                        let finalHeight = calculateHeightWhenScrollUp(changedHeight: targetHeight, viewHeight: baseViewHeight)
                        
                        gesture.view?.frame.origin.y -= transition.y
                        output.heightRelay.accept(finalHeight)
                    }
                    else if gesture.velocity(in: gesture.view).y > 0 {
                        let targetHeight = calculateHeightWhenScrollDown(changedHeight: gesture.view?.frame.size.height ?? 0, viewHeight: baseViewHeight)
                        let finalHeight = calculateHeightWhenScrollDown(changedHeight: targetHeight, viewHeight: baseViewHeight)
                        
                        if finalHeight > baseViewHeight * 0.2 {
                            gesture.view?.frame.origin.y -= transition.y
                        }
                        output.heightRelay.accept(finalHeight)
                    }
                    gesture.setTranslation(.zero, in: gesture.view)
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        }
        
        return output
    }
    
    // calculate height when up gesture
    private func calculateHeightWhenScrollUp(changedHeight: CGFloat, viewHeight: CGFloat) -> CGFloat {
        if changedHeight > viewHeight * 0.5 {
            return viewHeight * 0.8
        }
        else if changedHeight > viewHeight * 0.15 {
            return viewHeight * 0.4
        }
        return viewHeight * 0.2
    }
    
    // calculate height when down gesture
    private func calculateHeightWhenScrollDown(changedHeight: CGFloat, viewHeight: CGFloat) -> CGFloat {
        if changedHeight > viewHeight * 0.35{
            return viewHeight * 0.4
        }
        if changedHeight > viewHeight * 0.15 {
            return viewHeight * 0.2
        }
        return viewHeight * 0.8
    }
}


