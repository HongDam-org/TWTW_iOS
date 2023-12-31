//
//  FriendListTableViewCell.swift
//  TWTW
//
//  Created by 정호진 on 11/29/23.
//

import Foundation
import SnapKit
import UIKit

/// 친구 목록
final class FriendListTableViewCell: UITableViewCell {
    
    /// 유저 프로필 이미지
    private lazy var userProfilImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    /// 유저 라벨
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// Add UI
    private func addSubViews() {
        addSubview(userProfilImageView)
        addSubview(userNameLabel)
        
        constraints()
    }
    
    /// Set AutoLayout
    private func constraints() {
        userProfilImageView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(10)
            make.leading.equalToSuperview()
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(userProfilImageView.snp.centerY)
            make.leading.equalTo(userProfilImageView.snp.trailing).offset(20)
        }
    }
    
    
    /// Input Data
    /// - Parameter info: 사용자 정보
    func inputData(info: Friend) {
        userProfilImageView.image = UIImage(named: "profile")
        userNameLabel.text = info.nickname
    }
    
}
