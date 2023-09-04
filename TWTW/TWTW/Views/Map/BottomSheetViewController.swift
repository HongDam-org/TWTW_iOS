//
//  BottomSheetViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/13.
//
import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class BottomSheetViewController: UIViewController {
    /// MARK: 하단 UIView
    private let bottomSheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    weak var delegate: BottomSheetDelegate?
    private let disposeBag = DisposeBag()
     let viewModel = BottomSheetViewModel()
    
    private var selectedTabItemTitle: String?

    /// MainMapViewController view의 높이
    var viewHeight: BehaviorRelay<CGFloat> = BehaviorRelay(value: CGFloat())
    
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
    }
    
    // MARK: - Functions
    
    /// MARK: Add UI
    private func addSubViews() {
        view.addSubview(bottomSheetView)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        bottomSheetView.addGestureRecognizer(panGesture)
        configureConstraints()
    }
    
    /// MARK: Set AutoLayout
    private func configureConstraints() {
        viewModel.setupHeight(viewHeight: viewHeight.value)
        var heightConstraint: Constraint? = nil
        bottomSheetView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            heightConstraint = make.height.equalTo(viewModel.minHeight).constraint
        }
        viewModel.heightConstraintRelay.accept(heightConstraint)
        
    }
    

    /// panning Gesture
    @objc
    private func handlePan(_ panGesture: UIPanGestureRecognizer){
        viewModel.handlePan(gesture: panGesture, view: view)
            .subscribe(onNext: { [weak self] targetHeight in
                guard let self = self else { return }
                
                self.delegate?.didUpdateBottomSheetHeight(targetHeight)
                
                UIView.animate(withDuration: 0.2) {
                    self.viewModel.heightConstraintRelay.accept(self.viewModel.heightConstraintRelay.value?.update(offset: targetHeight))
                    self.view.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
    }
}

