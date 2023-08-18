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
    
    var heightConstraintRelay: BehaviorRelay<Constraint?> = BehaviorRelay(value: nil)
    
    var minHeight: CGFloat = 0.0
    var midHeight: CGFloat = 0.0
    var maxHeight: CGFloat = 0.0
    
    init(viewHeight: CGFloat) {
        setupHeight(viewHeight: viewHeight)
    }
    
    private func setupHeight(viewHeight: CGFloat) {
        self.minHeight = viewHeight * 0.2
        self.midHeight = viewHeight * 0.5
        self.maxHeight = viewHeight * 0.8
    }
    
    func calculateTargetHeight(currentHeight: CGFloat, translationY: CGFloat) -> CGFloat {
        let newHeight = currentHeight - translationY
        return min(max(newHeight, minHeight * 0.8), maxHeight)
    }
    
    func calculateFinalHeight(changedHeight: CGFloat) -> CGFloat {
        if changedHeight > midHeight {
            return maxHeight
        } else if changedHeight > minHeight {
            return midHeight
        } else {
            return minHeight
        }
    }
    
    func handlePan(gesture gestureRecognizer: UIPanGestureRecognizer, view: UIView) -> Observable<CGFloat> {
        let translation = gestureRecognizer.translation(in: view)
        let height = heightConstraintRelay.value?.layoutConstraints.first?.constant ?? CGFloat()

        let changedHeight = calculateTargetHeight(currentHeight: height, translationY: translation.y)

        heightConstraintRelay.accept(heightConstraintRelay.value?.update(offset: changedHeight))

        let targetHeight = calculateFinalHeight(changedHeight: changedHeight)
        
        return gestureRecognizer.rx.event
            .filter { $0.state == .ended || $0.state == .cancelled }
            .map { _ in targetHeight }
    }
}
