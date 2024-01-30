//
//  UIColor+IA.swift
//  IntermissionApp
//
//  Created by Louis Tur on 12/26/18.
//  Copyright © 2018 intermissionsessions. All rights reserved.
//

import UIKit

/*
 Simplifying Conversions
 */
extension UIColor {
    
    /**
    Simple conversion that takes the Int value passed and divides it by 255.0. Alpha defaults to 1.0
     Also works by passing in hex components, for ex:
     
     Target: 0xFFFFFF
     Usage:  UIColor(r: 0xFF, g: 0xFF, b: 0xFF
     */
    convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1.0) {
        self.init( red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a )
    }
    
    /**
     Convert hex value. Alpha defaults to 1.0
     
     Target: 0xFFFFFF
     Usage:  UIColor(rgb: 0xFFFFFF)
     */
    convenience init(rgb: Int, a: CGFloat = 1.0) {
        self.init( r: (rgb >> 16) & 0xFF, g: (rgb >> 8) & 0xFF, b: rgb & 0xFF, a: a)
    }
    
    /**
     Converts a hex string to a color. Alpha is always 1.0.
     
     Target: "#FFFFFFF"
     Usage:  UIColor.hex("#FFFFFFF")
     */
    class func hex(_ hex: String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                       green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                       blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                       alpha: CGFloat(1.0)
        )
    }
    
}

/*
 Colors used in app
 
 */
extension UIColor {
    
    /// "Dark Blue Grey", (29, 55, 64)
    class var textColor: UIColor { return .darkBlueGrey }
    
    /// "Battleship Grey" (101, 127, 135)
    class var lightTextColor: UIColor { return .battleshipGrey }
    
    /// "NavBar Green"
    class var titleTextColor: UIColor { return .navBarGreen }
    
    class var tagTextColor: UIColor { return UIColor(r: 175, g: 168, b: 179) }

    class var navBarGreen: UIColor { return UIColor(rgb: 0x1D3740) }
    
    /// "Anti-flash white" #F2F2F2, web-friendly
    class var background: UIColor { return UIColor(rgb: 0xF2F2F2) }
    
    /// "Pale Lavendar", (243, 239, 245)
    class var secondaryBackground: UIColor { return .paleLavendar }
    
    /// "Bright Cyan", (82, 209, 220)
    class var cta: UIColor { return .brightCyan }
    
    /// "Dark Cyan", (34, 159, 170)
    class var ctaHighlighted: UIColor { return .darkCyan }
    
    /// "Light Teal", (138, 218, 189)
    class var accent: UIColor { return .lightGreen }
    
    /// Facebook Blue, From https://developers.facebook.com/docs/facebook-login/userexperience/
    class var facebookBlue: UIColor { return UIColor(rgb: 0x4267B2) }
    
    class var facebookBlueDark: UIColor { return UIColor(rgb: 0x264382) }
    
    // MARK: - Official Style Guide -
    
    /// Hex #8ADABD / R: 138, G: 218, B: 189 / a.k.a "Light Teal"
    class var lightGreen: UIColor { return UIColor(rgb: 0x8ADABD) }
    
    /// Hex #52D1DC / R: 82, G: 209, B: 220
    class var brightCyan: UIColor { return UIColor(rgb: 0x52d1dc) }
    
    /// Hex #229FAA / Not from official guide, derived from "brightCyan" for highlight states
    class var darkCyan: UIColor { return UIColor(rgb: 0x229FAA) }
    
    /// Hex: #657F87 / R: 101, G: 127, B: 135
    class var battleshipGrey: UIColor { return UIColor(rgb: 0x657f87) }
    
    /// Hex: #1D3740 / R: 29, G: 55, B: 64
    class var darkBlueGrey: UIColor { return UIColor(rgb: 0x1d3740) }
    
    /// Hex: #F3EFF5 / R: 243, G: 239, B: 245
    class var paleLavendar: UIColor { return UIColor(rgb: 0xf3eff5) }
    
    
    /// Hex: #8ADABD / R: 138, G: 218, B: 189
    class var lightTeal: UIColor { return UIColor(r: 138, g: 218, b: 189) }
}
