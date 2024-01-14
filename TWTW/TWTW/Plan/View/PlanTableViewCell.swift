//
//  PlanTableViewCell.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/01.
//

import RxSwift
import UIKit

final class PlanTableViewCell: UITableViewCell {
    var disposeBag = DisposeBag()
    
    private lazy var planStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 5
        return stackView
    }()
    
    private lazy var planName: UILabel = {
        let label = UILabel()
        label.text = "약속"
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    private lazy var groupName: UILabel = {
        let label = UILabel()
        label.text = "섭"
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = .gray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// addSubViews()
    private func addSubViews() {
        contentView.addSubview(planStackView)
        planStackView.addArrangedSubview(planName)
        planStackView.addArrangedSubview(groupName)
        configureConstraints()
    }
    
    /// addSubViews()
    private func configureConstraints() {
        planStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview().inset(5)
        }
        
    }
    
    /// configure
    func inputData(plan: Plan) {
        self.planName.text = plan.placeDetails.placeName
        self.groupName.text = plan.groupInfo.name
    }
}
