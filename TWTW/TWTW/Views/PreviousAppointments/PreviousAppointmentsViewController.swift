//
//  PreviousAppointmentsViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/26.
//

import Foundation
import UIKit
import SnapKit
import RxCocoa
import RxSwift

//이전 약속들 목록
final class PreviousAppointmentsViewController: UIViewController {

    /// MARK:
    private lazy var tbtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("asdfsfsf", for: .normal)
        btn.backgroundColor = .darkGray
        btn.titleLabel?.font = .systemFont(ofSize: 15)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    
    private let disposeBag = DisposeBag()
    
    // MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        addSubViews()
        bind()
    }
    
    // MARK: - Fuctions
    
    /// MARK: Add  UI
    private func addSubViews() {
        view.addSubview(tbtn)
        configureConstraints()
    }
    
    /// MARK:
    private func configureConstraints(){
        tbtn.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
        }
    }
    
    
    
    /// MARK:
    private func bind(){
        tbtn.rx.tap
            .bind {
                print("clcikdfakls")
            }
            .disposed(by: disposeBag)
    }
}

