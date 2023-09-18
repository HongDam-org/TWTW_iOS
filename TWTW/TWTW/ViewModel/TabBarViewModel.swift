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

///TabBarViewModel
final class TabBarViewModel {
    // bottomSheetView 높이를 나타내는 BehaviorRelay
    var heightConstraintRelay: BehaviorRelay<Constraint?> = BehaviorRelay(value: nil)
    /// mark - 가장 낮은 높이
    var noneHeight: CGFloat = 0.0
    
    /// mark - 최소 높이
    var minHeight: CGFloat = 0.0
    
    /// mark - 중간 높이
    var midHeight: CGFloat = 0.0
    
    /// mark - 최대 높이
    var maxHeight: CGFloat = 0.0
    let acceptableRange = 0.1  // 자연스러운 변화
    // handlePan 동작에서 처음 터치된 위치
    var initialTouchY: CGFloat = 0.0
    var gapTouchY: CGFloat = 0.0
    
    // 높이 설정 로직
    func setupHeight(viewHeight: CGFloat) {
        self.noneHeight = viewHeight * 0.15
        self.minHeight = viewHeight * 0.3
        self.midHeight = viewHeight * 0.6
        self.maxHeight = viewHeight * 0.8
    }
    
     //목표 높이 계산
//    func calculateTargetHeight(viewHeight: CGFloat) -> CGFloat {
//        let newHeight = viewHeight
//        return min(max(newHeight, minHeight * (1 - acceptableRange)), maxHeight * (1 + acceptableRange))
//    }
//    
    // 최종 높이 계산
    func calculateFinalHeight(changedHeight: CGFloat) -> CGFloat {
        if changedHeight > midHeight {
            return maxHeight
        } else if changedHeight > minHeight {
            return midHeight
        } else if changedHeight > noneHeight{
            return minHeight
        }else {
            return noneHeight
        }
    }
    
    // 화면 이동 처리
//    func handlePan(gesture gestureRecognizer: UIPanGestureRecognizer, view: UIView) -> Observable<CGFloat> {
//        if gestureRecognizer.state == .began {
//            initialTouchY = gestureRecognizer.location(in: view).y
//        }
//
//        let lastTouchY = gestureRecognizer.location(in: view).y
//        var heightByTouch: CGFloat = 0.0
//        gapTouchY = (initialTouchY - lastTouchY) // 이동된 Y좌표 갭
//
//        let floorViewBoundsHeight = floor(view.bounds.height)
//        let ceilMaxHeight = ceil(maxHeight)
//
//        if floorViewBoundsHeight > ceilMaxHeight {
//            heightByTouch = minHeight + gapTouchY
//        } else {
//            heightByTouch = view.bounds.height + gapTouchY
//        }
//        let newHeight = calculateTargetHeight(viewHeight: heightByTouch)
//
//        heightConstraintRelay.accept(heightConstraintRelay.value?.update(offset: newHeight))
//
//        let targetHeight = calculateFinalHeight(changedHeight: newHeight)
//        return gestureRecognizer.rx.event
//            .filter { $0.state == .ended || $0.state == .cancelled }
//            .map { _ in targetHeight }
//
//    }
//
}


