//
//  Color.swift
//  TWTW
//
//  Created by 박다미 on 2023/08/27.
//

import Foundation
import UIKit
// Color
extension UIColor {
    
    /// 맵 위 반경
    static let mapCircleColor = UIColor(named: MapColors.mapCircleColor.rawValue)
    
    /// 길찾기
    /// stroke line color
    static let mapStrokeColor = UIColor(named: MapColors.mapStrokeColor.rawValue)

    /// line color
    static let mapLineColor = UIColor(named: MapColors.mapLineColor.rawValue)
    
    /// profile Textfield background Color
    static let profileTextFieldColor = UIColor(named: ProfileColors.profileTextFieldColor.rawValue)

    convenience init(hexCode: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hexCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
    
}

enum MapColors: String {
    case mapCircleColor
    case mapStrokeColor
    case mapLineColor
}

enum ProfileColors: String {
    case profileTextFieldColor
}
