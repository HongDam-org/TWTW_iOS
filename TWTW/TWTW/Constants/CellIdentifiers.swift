//
//  Cell.swift
//  TWTW
//
//  Created by 박다미 on 2023/11/06.
//

import Foundation

///  Cell식별 Enum
enum CellIdentifier: String {
    case planTableViewCell = "PlanTableViewCell"
    case participantsTableViewCell = "ParticipantsTableViewCell"
    case searchPlacesTableViewCell = "SearchPlacesTableViewCell"
    
    /// NearbyPlacesCollectionViewCell.cellIdentifier
    case nearbyPlacesCollectionViewCell = "NearbyPlacesCollectionViewCell"

    case tabBarItemsCollectionViewCell = "TabBarItemsCollectionViewCell"
    
    case friendsListColletionViewCell = "FriendsListColletionViewCell"
}
