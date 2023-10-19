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
    var noneHeight: CGFloat = 0.0
    var minHeight: CGFloat = 0.0
    var midHeight: CGFloat = 0.0
    var maxHeight: CGFloat = 0.0
    let acceptableRange = 0.1  // 자연스러운 변화
    
    // handlePan 동작에서 처음 터치된 위치
    var initialTouchY: CGFloat = 0.0
    
    // 높이 설정 로직
    func setupHeight(viewHeight: CGFloat) {
        self.noneHeight = viewHeight * 0.15
        self.minHeight = viewHeight * 0.3
        self.midHeight = viewHeight * 0.6
        self.maxHeight = viewHeight * 0.8
    }

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
}


