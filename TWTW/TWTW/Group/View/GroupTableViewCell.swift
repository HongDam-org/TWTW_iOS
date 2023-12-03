//
//  GroupTableViewCell.swift
//  TWTW
//
//  Created by 정호진 on 11/28/23.
//

import Foundation
import SnapKit
import UIKit

final class GroupTableViewCell: UITableViewCell {
    
    /// 그룹 이미지
    private lazy var groupImage: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 20
        return view
    }()
    
    /// 그룹 이름
    private lazy var groupName: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25)
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
        addSubview(groupImage)
        addSubview(groupName)
        constraints()
    }
    
    /// Set AutoLayout
    private func constraints() {
        groupImage.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        groupName.snp.makeConstraints { make in
            make.centerY.equalTo(groupImage.snp.centerY)
            make.leading.equalTo(groupImage.snp.trailing).offset(20)
        }
    }
    
    /// Input Data about Group Item List
    /// - Parameter item: Group Item
    func inputData(item: Group) {
        guard let _ = item.groupImage, let name = item.name else { return }
        groupImage.image = UIImage(named: "profile")
        groupName.text = name
    }
}
