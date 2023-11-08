//
//  FriendsListViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/26.
//

import Foundation
import UIKit

// 친구목록
final class FriendsListViewController: UIViewController {
    let cellWithReuseIdentifier = "FriendsListColletionViewCell"
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .gray
        return collectionView
        
    }()
    
    // MARK: View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(FriendsListColletionViewCell.self, forCellWithReuseIdentifier: cellWithReuseIdentifier)
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
    }
    
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FriendsListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.size.width * 0.2
        let cellHeight = collectionView.frame.size.height * 0.95
        return CGSize(width: cellWidth, height: cellHeight)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension FriendsListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return friendsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellWithReuseIdentifier,
                                                            for: indexPath) as? FriendsListColletionViewCell else {
            return UICollectionViewCell()
        }
        
        if let imageName = friendsList[indexPath.row].imageName {
            cell.imageView.image = UIImage(named: imageName)
        } else {
            cell.imageView.image = nil
        }
        
        cell.nameLabel.text = friendsList[indexPath.row].nameLabel
        return cell
    }
}
