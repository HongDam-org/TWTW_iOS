//
//  MapBottomSheet.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/11.
//

import SnapKit
import RxSwift
import RxCocoa
import UIKit

///동적 높이 변화델리게이트 - BottomSheetDelegate
protocol BottomSheetDelegate: AnyObject {
    func didUpdateBottomSheetHeight(_ height: CGFloat)
}
///BottomSheetContentViewController
class BottomSheetViewController: UIViewController {
    var minHeight: CGFloat = 0.0
    var midHeight: CGFloat = 0.0
    var maxHeight: CGFloat = 0.0
    
 
    weak var delegate: BottomSheetDelegate?//MainMapVC에서 터치영역때문에 동적인 바텀시트 크기 전달

    //바텀비트
    private let bottomSheetView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20 // 모서리 둥글게 설정
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // 상단 양쪽 모서리만 둥글게 설정
        return view
    }()
    private var bottomSheetHeightConstraint: Constraint?
    
    //viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeight()
        setupBottomSheet()
        
    }
    //setupHeight() -특정 세구간 높이 지정
    private func setupHeight(){
        minHeight = view.frame.height * 0.2
        midHeight = view.frame.height * 0.5
        maxHeight = view.frame.height * 0.8
    }
    private func setupBottomSheet() {
        
        view.addSubview(bottomSheetView) //addSubview
        bottomSheetView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            bottomSheetHeightConstraint = make.height.equalTo(minHeight).constraint // 초기 높이 설정
        }
        
        //UIPanGestureRecognizer 바텀시트에 드레그 제스처
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        bottomSheetView.addGestureRecognizer(panGesture)
    }
    // MainMapViewController에 전달할 바텀시트높이
    
    
    
    //handlePan(_ gestureRecognizer: ) -바텀 시트 드래그 제스처 이벤트 처리함수
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let heightConstraint = bottomSheetHeightConstraint else {
            return
        }
        //heightConstraint : Constraint?, Constraint-layoutConstraints: [LayoutConstraint]
        let translation = gestureRecognizer.translation(in: view)//드래그 계산
        let newHeight = heightConstraint.layoutConstraints.first!.constant - translation.y//새로운 높이 계산([현재바텀시트높이] - 드래그계산으로 변화된 y)
        
        let changedHeight = min(max(newHeight,minHeight*0.8), maxHeight)//새로운 높이를 최소,중간, 최대높이 사이 제한
        
        heightConstraint.update(offset: changedHeight) //heightConstraint.update
        gestureRecognizer.setTranslation(.zero, in: view) //드래그 초기화
        
        //드래그 놓았을때 인식 or 동작취소
        if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
            let targetHeight: CGFloat
            
            if changedHeight > midHeight {
                targetHeight = maxHeight
            } else if changedHeight > minHeight {
                targetHeight = midHeight
            } else {
                targetHeight = minHeight
            }
            // 델리게이트를 통해 새로운 높이 업데이트 전달
                       delegate?.didUpdateBottomSheetHeight(targetHeight)
            //애니메이션으로 변화
            UIView.animate(withDuration: 0.3) {
                heightConstraint.update(offset: targetHeight)
                self.view.layoutIfNeeded()
            }
            
        }
    }
    
    
    
}
