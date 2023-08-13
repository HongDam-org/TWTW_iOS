//
//  MainMapViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/11.
//

import UIKit
import NMapsMap
import RxCocoa
import RxSwift
import SnapKit
import CoreLocation //위치정보

///MainMapViewController - 지도화면
final class MainMapViewController: UIViewController  {
    
    /// MARK: 지도 아랫부분 화면
    private lazy var bottomSheetViewController: BottomSheetViewController = {
        let viewModel = BottomSheetViewModel(viewHeight: self.view.frame.height)// 필요한 초기값으로 설정
        let view = BottomSheetViewController(viewModel: viewModel)
        view.delegate = self
        return view
    }()
    
    /// MARK: 네이버 지도
    private lazy var mapView: NMFMapView = {
        var view = NMFMapView()
        view.positionMode = .normal
        return view
    }()
    
    private let disposeBag = DisposeBag()
    private let viewModel = MainMapViewModel()
    
    // MARK: - View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        viewModel.setupLocationManager()
        
        
    }
    // MARK: -  View Did Appear
    override func viewDidAppear(_ animated: Bool) {
        addSubViews()
    }
    
    
    // MARK: - Fuctions
    
    /// MARK: Add UI
    private func addSubViews() {
        view.addSubview(bottomSheetViewController.view)
        bottomSheetViewController.didMove(toParent: self)
        configureConstraints()
    }
    
    /// MARK: Configure Constraints UI
    private func configureConstraints() {
        bottomSheetViewController.view.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(bottomSheetViewController.viewModel.minHeight)
        }
    }
    
    /// setupMapView()
    private func setupMapView() {
        mapView = NMFMapView(frame: view.frame)
        mapView.positionMode = .normal
        view.addSubview(mapView)
    }
    
}

// BottomSheetDelegate 프로토콜
extension MainMapViewController: BottomSheetDelegate {
    func didUpdateBottomSheetHeight(_ height: CGFloat) {
        bottomSheetViewController.view.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
