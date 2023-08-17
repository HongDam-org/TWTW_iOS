//
//  BottomSheetViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/13.
//

import SnapKit
import RxSwift
import RxCocoa
import UIKit

///BottomSheetContentViewController
final class BottomSheetViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    var viewModel: BottomSheetViewModel!
    
    //바텀비트
    private let bottomSheetView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20 // 모서리 둥글게 설정
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // 상단 양쪽 모서리만 둥글게 설정
        return view
    }()
    
    private var bottomSheetHeightConstraint: Constraint?
    weak var delegate: BottomSheetDelegate?
    
    convenience init(viewModel: BottomSheetViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    // MARK: -  View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        
    }
    /// MARK: Add UI
    private func addSubViews() {
        view.addSubview(bottomSheetView)
        configureConstraints()
    }
    /// MARK: Configure Constraints UI
    private func configureConstraints() {
        bottomSheetView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            bottomSheetHeightConstraint = make.height.equalTo(viewModel.minHeight).constraint
        }
        
        //UIPanGestureRecognizer 바텀시트에 드레그 제스처
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        bottomSheetView.addGestureRecognizer(panGesture)
    }
    
    //handlePan(_ gestureRecognizer: ) -바텀 시트 드래그 제스처 이벤트 처리함수
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let heightConstraint = bottomSheetHeightConstraint else {
            return
        }
        let translation = gestureRecognizer.translation(in: view)//드래그 계산
        guard let height = heightConstraint.layoutConstraints.first?.constant else { return }
        
        let changedHeight = viewModel.calculateTargetHeight(currentHeight: height, translationY: translation.y)
        
        heightConstraint.update(offset: changedHeight) //heightConstraint.update
        gestureRecognizer.setTranslation(.zero, in: view) //드래그 초기화
        
        //드래그 놓았을때 인식 or 동작취소
        if gestureRecognizer.state == .ended || gestureRecognizer.state == .cancelled {
            let targetHeight = viewModel.calculateFinalHeight(changedHeight: changedHeight)
            
            
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


///동적 높이 변화델리게이트 - BottomSheetDelegate
protocol BottomSheetDelegate: AnyObject {
    func didUpdateBottomSheetHeight(_ height: CGFloat)
}
