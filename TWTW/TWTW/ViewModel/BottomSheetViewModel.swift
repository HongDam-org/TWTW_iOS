//
//  BottomSheetViewModel.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/13.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

///BottomSheetViewModel
final class BottomSheetViewModel {
    var minHeight: CGFloat = 0.0
    var midHeight: CGFloat = 0.0
    var maxHeight: CGFloat = 0.0
    
    init(viewHeight: CGFloat) {
        //setupHeight() -특정 세구간 높이 지정
        self.minHeight = viewHeight * 0.2
        self.midHeight = viewHeight * 0.5
        self.maxHeight = viewHeight * 0.8
    }
    
    func calculateTargetHeight(currentHeight: CGFloat, translationY: CGFloat) -> CGFloat {
        let newHeight = currentHeight - translationY
        let changedHeight = min(max(newHeight, minHeight * 0.8), maxHeight)
        return changedHeight
    }
    
    ///특정 구간으로 지정
    func calculateFinalHeight(changedHeight: CGFloat) -> CGFloat {
        if changedHeight > midHeight {
            return maxHeight
        } else if changedHeight > minHeight {
            return midHeight
        } else {
            return minHeight
        }
    }
}
