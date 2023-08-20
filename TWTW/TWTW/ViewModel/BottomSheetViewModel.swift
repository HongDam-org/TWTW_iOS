//
//  BottomSheetViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/13.
//

import Foundation
import RxSwift
import RxCocoa
import SnapKit

final class BottomSheetViewModel {
    
    /// bottomSheetView 높이 Relay
    var heightConstraintRelay: BehaviorRelay<Constraint?> = BehaviorRelay(value: nil)
    
    /// 최소 높이
    var minHeight: CGFloat = 0.0
    
    /// 중간 높이
    var midHeight: CGFloat = 0.0
    
    /// 최고 높이
    var maxHeight: CGFloat = 0.0
    let acceptableRange = 0.1 // 자연스러운 변화
    //handlePan 동작에서 처음 터치된 위치
    var initaialTouchY : CGFloat = 0.0
    // MARK: - Logic
    
    /// MARK: setting Heights
    func setupHeight(viewHeight: CGFloat) {
        self.minHeight = viewHeight * 0.2
        self.midHeight = viewHeight * 0.5
        self.maxHeight = viewHeight * 0.8
    }
    
    /// MARK: calculate Target Height
    func calculateTargetHeight(viewHeight: CGFloat) -> CGFloat {
        let newHeight = viewHeight
        return min(max(newHeight, minHeight * (1 - acceptableRange)), maxHeight * (1 + acceptableRange))
    }
    
    /// MARK: calculate Final Height
    func calculateFinalHeight(changedHeight: CGFloat) -> CGFloat {
        if changedHeight > midHeight {
            return maxHeight
        } else if changedHeight > minHeight {
            return midHeight
        } else {
            return minHeight
        }
    }
    
    /// MARK: when panning Screen
    func handlePan(gesture gestureRecognizer: UIPanGestureRecognizer, view: UIView) -> Observable<CGFloat> {
        //처음 터치위치에 대한 처리
        if gestureRecognizer.state == .began{
            initaialTouchY = gestureRecognizer.location(in: view).y
        }
        
        let lastTouchY = gestureRecognizer.location(in: view).y
        var heightbyTouch :CGFloat = 0.0
        var gapTouchY = (initaialTouchY - lastTouchY) //이동된 Y좌표 갭
        
        //초기 화면일 경우, 소수점차이문제로 maxHeight에서 변환시 나는 이슈 가능성 -> Int
        var floorViewBoundsHeight = floor(view.bounds.height)
        var ceilMaxHeight = ceil(maxHeight)
        //초기화면의 view높이일때:
        if floorViewBoundsHeight > ceilMaxHeight {
            heightbyTouch = minHeight + gapTouchY
        }
        else {//view.boudns.height의 초기화면 이후에는 최대 maxHeight
            heightbyTouch = view.bounds.height + gapTouchY
        }
        let newHeight = calculateTargetHeight(viewHeight: heightbyTouch)
        
        heightConstraintRelay.accept(heightConstraintRelay.value?.update(offset: newHeight))
        
        let targetHeight = calculateFinalHeight(changedHeight: newHeight)
        return gestureRecognizer.rx.event
            .filter { $0.state == .ended || $0.state == .cancelled }
            .map { _ in targetHeight }
    }
    
}
