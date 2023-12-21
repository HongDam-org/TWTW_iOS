//
//  NotificationTableViewCell.swift
//  TWTW
//
//  Created by 정호진 on 12/22/23.
//

import Foundation
import SnapKit
import UIKit

final class NotificationTableViewCell: UITableViewCell {
    
    /// 제목 라벨
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    /// 시간 라벨
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    /// 오른쪽 뷰
    private lazy var rightImage: UIImageView = {
        let view = UIImageView(image: UIImage(systemName: "chevron.right")?.resize(newWidth: 30))
        return view
    }()
    
    // MARK: - init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubViews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// Add UI
    private func addSubViews() {
        addSubview(titleLabel)
        addSubview(timeLabel)
        addSubview(rightImage)
        
        constraints()
    }
    
    /// Set Constraints
    private func constraints() {
        titleLabel.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.leading.equalTo(titleLabel.snp.trailing).offset(10)
            make.trailing.equalTo(rightImage.snp.leading)
        }
        
        rightImage.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.trailing.equalToSuperview().offset(-10)
        }
    }
    
    /// Input Data
    /// - Parameter title: title
    func inputData(title: String) {
        titleLabel.text = title
    }
}
