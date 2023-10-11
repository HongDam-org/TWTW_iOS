//
//  SearchPlacesMapViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/22.
//

import Foundation
import UIKit

///mark: - 검색 결과를 표시하는 새로운 View Controller
final class SearchPlacesMapViewController: UIViewController {
    /// MARK: 서치바UI
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "장소, 주소 검색"
        searchBar.showsCancelButton = false
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = .white
        searchBar.layer.cornerRadius = 15
        searchBar.clipsToBounds = true
        
        ///MARK: searchBar shadow
        searchBar.layer.shadowColor = UIColor.gray.cgColor
        searchBar.layer.shadowOpacity = 0.5
        searchBar.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        searchBar.layer.shadowRadius = 1.5
        searchBar.layer.masksToBounds = false
        
        return searchBar
    }()
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setNavi()
        addSubViews_SearchBar()
        searchBar.delegate = self
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hiddenNavi()
        
    }
    ///mark: - 네비게이션 item보이기
    private func setNavi(){
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    ///mark: - 네비게이션 item숨기기
    private func hiddenNavi(){
        /// SearchPlacesMapViewController에서 뒤로 돌아갈 때 MainMapVC로 돌아가면서 네비게이션 바를 숨김
        if let mainMapVC = navigationController?.viewControllers.first(where: { $0 is MainMapViewController }) as? MainMapViewController {
            mainMapVC.navigationController?.setNavigationBarHidden(true, animated: false)
        }
        
    }
    /// MARK: Add  UI - SearchBar
    private func addSubViews_SearchBar(){
        view.addSubview(searchBar)
        configureConstraints_SearchBar()
        
    }
    /// MARK: Configure   Constraints UI - SearchBar
    private func configureConstraints_SearchBar() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.trailing.equalToSuperview().inset(5)
        }
    }
}
extension SearchPlacesMapViewController : UISearchBarDelegate{
    
}
