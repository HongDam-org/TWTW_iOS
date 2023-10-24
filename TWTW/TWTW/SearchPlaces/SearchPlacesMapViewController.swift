//
//  SearchPlacesMapViewController.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/22.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Alamofire
import CoreLocation


/*
 "placeName" : "이디야커피 안성죽산점",
 "distance" : "435",
 "placeUrl" : "http://place.map.kakao.com/1562566188",
 "categoryName" : "음식점 > 카페 > 커피전문점 > 이디야커피",
 "addressName" : "경기 안성시 죽산면 죽산리 118-3",
 "roadAddressName" : "경기 안성시 죽산면 죽주로 287-1",
 "categoryGroupCode" : "CE7",
 "x" : "127.426865189637",
 "y" : "37.0764635355795"
 */

///mark: - 검색 결과를 표시하는 새로운 View Controller
final class SearchPlacesMapViewController: UIViewController {
    let disposeBag = DisposeBag()
    let cellIdentifier = "SearchPlacesTableViewCell"
    
    ///필터링지역들
    var filteredPlaces = [Place]()
    let viewModel: SearchPlacesMapViewModel
    
    /// MARK: 서치바UI
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "장소, 주소 검색"
        searchBar.showsCancelButton = false
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = .white
        searchBar.delegate = self
        return searchBar
    }()
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.tintColor = .black
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        //delegate, dataSource
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    init(viewModel: SearchPlacesMapViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavi()
        addSubViews_SearchBar()
        backButtonAction()
        
    }
    
    func checkAccess(searchText: String) {
        // 검색어를 URL 인코딩
        let encodedQuery = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let accessToken = KeychainWrapper.loadString(forKey: SignIn.accessToken.rawValue) ?? ""
        let headers: HTTPHeaders = ["Authorization": "Bearer \(accessToken)"]
        
        let url = "\(Domain.REST_API)\(SearchPath.placeAndCategory)?query=\(encodedQuery)&page=1&categoryGroupCode=NONE"
        
        AF.request(url, method: .get, headers: headers)
            .validate(statusCode: 200..<201)
            .responseDecodable(of: ResponseModel.self) { response in
                switch response.result {
                case .success(let data):
                    // 검색어를 포함하는 placeName을 가진 장소만 필터링으로 filteredPlaces에 추가
                    self.filteredPlaces = data.results.map { $0 }
                    
                case .failure(let error):
                    print(error)
                }
                self.tableView.reloadData()
            }
    }
    
    var naviBarHeight :CGFloat =  0.0
    var NaviBarWidth : CGFloat = 0.0
    
    ///mark: - 네비게이션 item보이기
    private func setNavi(){
        navigationController?.setNavigationBarHidden(true, animated: false)
        naviBarHeight = navigationController?.navigationBar.frame.height ?? 10
    }
    
    /// MARK: Add  UI - SearchBar
    private func addSubViews_SearchBar(){
        view.addSubview(searchBar)
        view.addSubview(backButton)
        view.addSubview(tableView)
        
        tableView.register(SearchPlacesTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        configureConstraints()
    }
    
    /// MARK: Configure   Constraints
    private func configureConstraints() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview().inset(naviBarHeight)
            make.trailing.equalToSuperview().inset(5)
        }
        
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalToSuperview().inset(5)
            make.width.height.equalTo(searchBar.snp.height)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    ///mark: 커스텀 네비게이션 뒤로가기 버튼
    private func backButtonAction(){
        backButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
/// MARK: Extension
extension SearchPlacesMapViewController : UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredPlaces = []
        }
        checkAccess(searchText: searchText)
    }
}

extension SearchPlacesMapViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SearchPlacesTableViewCell
        let place = filteredPlaces[indexPath.row]
        cell.configure(placeName: place.placeName, addressName: place.addressName, categoryName: place.categoryName)
        return cell
    }
}

extension SearchPlacesMapViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = filteredPlaces[indexPath.row]
        guard let placeX = Double(place.x) else { return }
        guard let placeY = Double(place.y) else { return }
        print(placeY)
        ///선택한 좌표이동
        viewModel.selectLocation(xCoordinate: placeX ,yCoordinate: placeY)
    }
}
