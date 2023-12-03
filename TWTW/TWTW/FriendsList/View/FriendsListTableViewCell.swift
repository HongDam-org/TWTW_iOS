//
//  FriendsListTableView.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/03.
//

import Foundation
import SnapKit
import UIKit

final class FriendsListTableViewCell: UITableViewCell {
    /// 사진
    private lazy var friendimageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    /// 이름
    private lazy var friendNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .brown
    }
    @available(*, unavailable)
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// addSubViews()
    private func addSubViews() {
        contentView.addSubview(friendimageView)
        contentView.addSubview(friendNameLabel)
        configureConstraints()
    }
    
    /// Configure Constraints UI
    private func configureConstraints() {
        friendimageView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview().inset(3)
            make.height.equalTo(friendimageView.snp.width)
        }
        
        friendNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(friendimageView.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
    }
    /// configure
    func configure(friend: Friend) {
        //friendimageView.image = friend.nickname//이미지도 받아와야함
        friendNameLabel.text = friend.nickname
    }
}
