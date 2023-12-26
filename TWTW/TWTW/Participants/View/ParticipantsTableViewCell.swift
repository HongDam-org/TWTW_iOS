//
//  ParticipantsTableViewCell.swift
//  TWTW
//
//  Created by 박다미 on 2023/12/01.
//

import RxSwift
import SnapKit
import UIKit

final class ParticipantsTableViewCell: UITableViewCell {
    lazy var disposeBag = DisposeBag()
    let participantImageView = UIImageView()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.backgroundColor = .clear
        return label
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var callButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "phone"), for: .normal)
        btn.tintColor = .black
        return btn
    }()
    
    private lazy var locationButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "map"), for: .normal)
        btn.tintColor = .black
        return btn
    }()
    
    var callBtnTapObservable: Observable<Void> {
        return callButton.rx.tap.asObservable()
    }
    
    var locationBtnTapObservable: Observable<Void> {
        return locationButton.rx.tap.asObservable()
    }
    
    // MARK: - Init
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
        contentView.addSubview(participantImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(callButton)
        buttonStackView.addArrangedSubview(locationButton)

        configureConstraints()
    }
    
    /// configureConstraints()
    private func configureConstraints() {
        participantImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview().inset(10)
            make.width.equalTo(participantImageView.snp.height)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(participantImageView.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview().inset(10)
            make.width.equalTo(buttonStackView.snp.height).multipliedBy(2)
        }
    }
    
    /// configure
    func configure(participant: Friend) {
//        participantImageView.image = participant.participantsimage
        nameLabel.text = participant.nickname
    }
}
