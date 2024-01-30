//
//  UIFont+IA.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/1/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SwiftRichString

class Font {
    
    private static let baseFontName = "SoleilW01-"
    
    static let ctaButton: String = "ctaButton"
    static let invertedCTAButton: String = "invertedCTAButton"
    static let outlineCTAButtonHighlight: String = "outlineCTAButtonHighlighted"
    
    static let emptyViewDetail: String = "emptyViewDetail"
    static let emptyViewTitle: String = "emptyViewTitle"
    static let helperText: String = "helperText"
    static let loginButton: String = "loginButton"
    static let standardButton: String = "standardButton"
    static let feedModuleTitle: String = "feedModuleTitle"
    static let feedModuleTitleBold: String = "feedModuleTitleBold"
    static let videoCollectionCellTitle: String = "videoCollectionCellTitle"
    
    static let tableHeaderTitle: String = "tableHeaderTitle"
    static let largeHeaderTitle: String = "largeHeaderTitle"
    static let extraLargeHeaderTitle: String = "extraLargeHeaderTitle"
    
    static let chevronButtonNormal: String = "chevronButtonNormal"
    static let chevronButtonHighlighted: String = "chevronButtonHighlighted"
    static let dashboardVideoHeaderText: String = "dashboardVideoHeaderText"
    static let dashboardVideoTitle: String = "dashboardVideoTitle"
    static let durationText: String = "durationText"
    static let refreshControlText: String = "refreshControlText"
    static let vdpVideoTitleText: String = "vdpVideoTitleText"
    static let settingsCellText: String = "settingsCellText"
    
    static let profileJourneyTitleText: String = "profileJourneyTitleText"
    static let profileJourneyDateText: String = "profileJourneyDateText"
    
    static let alertTitleText: String = "alertControllerTitleText"
    static let alertDetailText: String = "alertControllerDetailText"
    
    static let onboardingTitleText: String = "onboardingTitleText"
    static let onboardingDetailText: String = "onboardingDetailText"
    
    static let storeRetreatCellTitleText: String = "storeRetreatCellTitleText"
    static let storeRetreatCellDetailText: String = "storeRetreatCellDetailText"
    
    static let retreatTitleText: String = "retreatTitleText"
    static let retreatDetailText: String = "retreatDetailText"
    static let retreatDetailSectionTitle: String = "retreatDetailSectionTitle"
    static let retreatPriceOptionCellText: String = "retreatPriceOptionCellText"
    static let retreatPriceOptionCellPriceText: String = "retreatPriceOptionCellPriceText"
    
    static let toastHighlightedText: String = "toastHighlightedText"
    static let toastRegularText: String = "toastRegularText"
    
    static func registerFonts() {
        
        let emptyViewTitleStyle = Style {
            $0.font = UIFont.title2
            $0.color = UIColor.textColor
            $0.alignment = .left
        }
        
        let ctaButtonStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .bold), size: 13.0)
            $0.color = UIColor.white
            $0.kerning = Kerning.point(1.18)
        }
        
        let invertedCTAButtonStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .bold), size: 13.0)
            $0.color = UIColor.cta
            $0.kerning = Kerning.point(1.18)
        }
        
        let outlineCTAButtonHighlightedStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .bold), size: 13.0)
            $0.color = UIColor.ctaHighlighted
            $0.kerning = Kerning.point(1.18)
        }
        
        let loginButtonStyle = ctaButtonStyle.byAdding {
            $0.color = UIColor.textColor
        }
        
        let emptyViewDetailStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .light), size: 15.0)
            $0.color = UIColor.textColor
            $0.minimumLineHeight = 15.0
            $0.maximumLineHeight = 18.0
            $0.alignment = .center
        }
        
        let helperTextStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .light), size: 12.0)
            $0.color = UIColor.textColor
            $0.alignment = .center
        }
        
        let standardButtonStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .bold), size: 13.0)
            $0.color = UIColor.navBarGreen
            $0.alignment = .center
            $0.kerning = Kerning.point(1.18)
        }
        
        let feedModuleTitleStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .lightItalic), size: 16.0)
            $0.color = UIColor.lightTextColor
            $0.alignment = .left
        }
        
        let feedModuleTitleStyleBold = feedModuleTitleStyle.byAdding {
            $0.font = UIFont(name: Font.identifier(for: .bold), size: 16.0)
            $0.kerning = Kerning.point(0.4)
            $0.color = UIColor.navBarGreen
        }
        
        let videoCollectionCellTitleStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .semiBold), size: 20.0)
            $0.color = UIColor.textColor
            $0.maximumLineHeight = 22.0
            $0.alignment = .left
        }
        
        let largeHeaderTitleStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .bold), size: 28.0)
            $0.color = UIColor.textColor
            $0.maximumLineHeight = 30.0
            $0.alignment = .left
        }
        
        let tableHeaderTitleStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .bold), size: 22.0)
            $0.color = UIColor.textColor
            $0.maximumLineHeight = 24.0
            $0.alignment = .left
        }
        
        let extraLargeHeaderTitleStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .semiBold), size: 32.0)
            $0.color = UIColor.textColor
            $0.maximumLineHeight = 34.0
            $0.alignment = .left
        }
        
        let chevronButtonNormalStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .bold), size: 12.0)
            $0.color = UIColor.cta
            $0.alignment = .left
            $0.kerning = Kerning.point(1.18)
        }
        
        let chevronButtonHighlightedStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .bold), size: 12.0)
            $0.color = UIColor.ctaHighlighted
            $0.alignment = .left
            $0.kerning = Kerning.point(1.18)
        }
        
        let dashboardVideoHeaderTextStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .lightItalic), size: 14.0)
            $0.color = UIColor.lightTextColor
            $0.alignment = .left
        }
        
        let dashboardVideoTitleStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .bold), size: 24.0)
            $0.color = UIColor.textColor
            $0.lineSpacing = 0.0
            $0.alignment = .left
            $0.maximumLineHeight = 28.0
        }
        
        let durationTextStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .italic), size: 12.0)
            $0.color = UIColor.lightTextColor
            $0.alignment = .left
            $0.kerning = Kerning.point(0.8)
        }
        
        let refreshControlStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .semiBoldItalic), size: 12.0)
            $0.color = UIColor.accent
            $0.alignment = .center
            $0.kerning = Kerning.point(1.18)
        }
        
        let vdpVideoTitleStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .bold), size: 30.0)
            $0.color = UIColor.titleTextColor
            $0.lineSpacing = 0.0
            $0.alignment = .left
            $0.maximumLineHeight = 32.0
        }
        
        // Store
        let storeRetreatTitleStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .semiBold), size: 30.0)
            $0.color = UIColor.textColor
            $0.alignment = .left
            $0.maximumLineHeight = 32.0
        }
        
        let storeRetreatDetailTextStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .regular), size: 16.0)
            $0.color = UIColor.lightTextColor
            $0.alignment = .left
        }
        
        // Retreat
        
        let retreatTitleStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .semiBold), size: 24.0)
            $0.color = UIColor.textColor
            $0.alignment = .left
            $0.maximumLineHeight = 24.0
        }
        
        let retreatDetailStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .regular), size: 14.0)
            $0.color = UIColor.lightTextColor
            $0.alignment = .left
            $0.minimumLineHeight = 15.0
            $0.maximumLineHeight = 16.0
            $0.lineSpacing = 4.0
        }
        
        let retreatDetailSectionTitleStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .semiBold), size: 18.0)
            $0.color = UIColor.textColor
            $0.alignment = .left
            $0.maximumLineHeight = 20.0
        }
        
        // Settings
        
        let settingsCellTextStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .semiBold), size: 14.0)
            $0.color = UIColor.textColor
            $0.alignment = .left
            $0.maximumLineHeight = 16.0
        }
        
        // Profile
        
        let profileJourneyTitleTextStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .semiBold), size: 20.0)
            $0.color = UIColor.textColor
            $0.alignment = .left
            $0.maximumLineHeight = 22.0
        }
        
        let profileJourneyDateTextStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .light), size: 12.0)
            $0.color = UIColor.lightTextColor
            $0.alignment = .left
            $0.maximumLineHeight = 14.0
            $0.kerning = Kerning.point(0.75)
        }
        
        // Alerts
        
        let alertTitleTextStlye = Style {
            $0.font = UIFont(name: Font.identifier(for: .bold), size: 28.0)
            $0.maximumLineHeight = 30.0
            $0.color = UIColor.textColor
            $0.alignment = .center
        }
        
        let alertDetailTextStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .regular), size: 14.0)
            $0.alignment = .center
            $0.color = UIColor.textColor
        }
        
        // Onboarding
        
        let onboardingTitleTextStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .bold), size: 28.0)
            $0.alignment = .left
            $0.color = UIColor.textColor
            $0.maximumLineHeight = 30.0
        }
        
        let onboardingDetailTextStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .regular), size: 14.0)
            $0.alignment = .left
            $0.color = UIColor.textColor
            $0.maximumLineHeight = 16.0
        }
        
        let retreatPriceOptionCellTextStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .semiBold), size: 18.0)
            $0.color = UIColor.textColor
            $0.alignment = .left
            $0.maximumLineHeight = 18.0
            $0.lineSpacing = 4.0
        }
        
        let retreatPriceOptionCellPriceTextStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .light), size: 16.0)
            $0.color = UIColor.textColor
            $0.alignment = .right
            $0.maximumLineHeight = 18.0
        }
        
        // Toasts
        
        let toastHighlightedStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .semiBold), size: 14.0)
            $0.color = UIColor.textColor
            $0.alignment = .left
            $0.maximumLineHeight = 16.0
        }
        
        let toastRegularStyle = Style {
            $0.font = UIFont(name: Font.identifier(for: .light), size: 14.0)
            $0.color = UIColor.textColor
            $0.alignment = .left
            $0.maximumLineHeight = 16.0
        }
        
        
        Styles.register(refreshControlText, style: refreshControlStyle)
        Styles.register(ctaButton, style: ctaButtonStyle)
        Styles.register(outlineCTAButtonHighlight, style: outlineCTAButtonHighlightedStyle)
        
        Styles.register(invertedCTAButton, style: invertedCTAButtonStyle)
        Styles.register(emptyViewDetail, style: emptyViewDetailStyle)
        Styles.register(emptyViewTitle, style: emptyViewTitleStyle)
        Styles.register(helperText, style: helperTextStyle)
        Styles.register(loginButton, style: loginButtonStyle)
        Styles.register(standardButton, style: standardButtonStyle)
        Styles.register(feedModuleTitle, style: feedModuleTitleStyle)
        Styles.register(feedModuleTitleBold, style: feedModuleTitleStyleBold)
        Styles.register(videoCollectionCellTitle, style: videoCollectionCellTitleStyle)
        
        Styles.register(tableHeaderTitle, style: tableHeaderTitleStyle)
        Styles.register(largeHeaderTitle, style: largeHeaderTitleStyle)
        Styles.register(extraLargeHeaderTitle, style: extraLargeHeaderTitleStyle)
        
        Styles.register(chevronButtonNormal, style: chevronButtonNormalStyle)
        Styles.register(chevronButtonHighlighted, style: chevronButtonHighlightedStyle)
        Styles.register(dashboardVideoHeaderText, style: dashboardVideoHeaderTextStyle)
        Styles.register(dashboardVideoTitle, style: dashboardVideoTitleStyle)
        Styles.register(durationText, style: durationTextStyle)
        Styles.register(vdpVideoTitleText, style: vdpVideoTitleStyle)
        Styles.register(settingsCellText, style: settingsCellTextStyle)
        Styles.register(profileJourneyTitleText, style: profileJourneyTitleTextStyle)
        Styles.register(profileJourneyDateText, style: profileJourneyDateTextStyle)
        Styles.register(alertTitleText, style: alertTitleTextStlye)
        Styles.register(alertDetailText, style: alertDetailTextStyle)
        Styles.register(onboardingTitleText, style: onboardingTitleTextStyle)
        Styles.register(onboardingDetailText, style: onboardingDetailTextStyle)
        Styles.register(storeRetreatCellTitleText, style: storeRetreatTitleStyle)
        Styles.register(storeRetreatCellDetailText, style: storeRetreatDetailTextStyle)
        Styles.register(retreatTitleText, style: retreatTitleStyle)
        Styles.register(retreatDetailText, style: retreatDetailStyle)
        Styles.register(retreatDetailSectionTitle, style: retreatDetailSectionTitleStyle)
        Styles.register(retreatPriceOptionCellText, style: retreatPriceOptionCellTextStyle)
        Styles.register(retreatPriceOptionCellPriceText, style: retreatPriceOptionCellPriceTextStyle)
        Styles.register(toastHighlightedText, style: toastHighlightedStyle)
        Styles.register(toastRegularText, style: toastRegularStyle)
    }
    
    enum Weight: String {
        case bold = "Bold"
        case boldItalic = "BoldIt"
        case book = "Book"
        case bookItalic = "BookIt"
        case extraBold = "ExtraBold"
        case extraBoldItalic = "ExtraboldIt"
        case italic = "It"
        case regular = "Regular"
        case light = "Light"
        case lightItalic = "LightIt"
        case semiBold = "SemiBold"
        case semiBoldItalic = "SemiboldIt"
    }
    
    static func identifier(for weight: Font.Weight) -> String {
        return Font.baseFontName + weight.rawValue
    }
}

extension UIFont {

    class var title1: UIFont { return UIFont.font(for: .title1) }
    
    class var title2: UIFont { return UIFont.font(for: .title2) }
    
    class var title3: UIFont { return UIFont.font(for: .title3) }
    
    class var largeTitle: UIFont { return UIFont.font(for: .largeTitle) }
    
    class var headline: UIFont { return UIFont.font(for: .headline) }
    
    // TODO: test with this subheadline, otherwise use regular implementations
    class var subheadline: UIFont {
        let metric = UIFontMetrics(forTextStyle: .subheadline)
        return metric.scaledFont(for: UIFont.font(for: .subheadline))
    }
    
    class var callout: UIFont { return UIFont.font(for: .callout) }
    
    class var body: UIFont { return UIFont.font(for: .body) }
    
    class var caption1: UIFont { return UIFont.font(for: .caption1) }
    
    class var caption2: UIFont { return UIFont.font(for: .caption2) }
    
    class var footnote: UIFont { return UIFont.font(for: .footnote) }
    
    private class func font(for textStyle: UIFont.TextStyle) -> UIFont {
        
        switch textStyle {
        case .title1:
            return UIFont(name: Font.identifier(for: .bold), size: 34.0) ?? UIFont.systemFont(ofSize: 34.0, weight: .bold)
        case .title2:
            return UIFont(name: Font.identifier(for: .bold), size: 28.0) ?? UIFont.systemFont(ofSize: 28.0, weight: .bold)
        case .title3:
            return UIFont(name: Font.identifier(for: .semiBold), size: 18.0) ?? UIFont.systemFont(ofSize: 18.0, weight: .semibold)
        case .largeTitle:
            return UIFont(name: Font.identifier(for: .regular), size: 20.0) ?? UIFont.systemFont(ofSize: 20.0, weight: .regular)
        case .headline:
            return UIFont(name: Font.identifier(for: .semiBold), size: 20.0) ?? UIFont.systemFont(ofSize: 20.0, weight: .semibold)
        case .subheadline:
            return UIFont(name: Font.identifier(for: .semiBold), size: 14.0) ?? UIFont.systemFont(ofSize: 14.0, weight: .semibold)
        case .callout:
            return UIFont(name: Font.identifier(for: .light), size: 14.0) ?? UIFont.systemFont(ofSize: 14.0, weight: .light)
        case .body:
            return UIFont(name: Font.identifier(for: .regular), size: 16.0) ?? UIFont.systemFont(ofSize: 16.0, weight: .regular)
        case .caption1:
            return UIFont(name: Font.identifier(for: .semiBold), size: 12.0) ?? UIFont.systemFont(ofSize: 12.0, weight: .semibold)
        case .caption2:
            return UIFont(name: Font.identifier(for: .light), size: 12.0) ?? UIFont.systemFont(ofSize: 12.0, weight: .light)
        case .footnote:
            return UIFont(name: Font.identifier(for: .semiBoldItalic), size: 14.0) ?? UIFont.systemFont(ofSize: 10.0, weight: .light)
        default:
            return UIFont(name: Font.identifier(for: .regular), size: 14.0)  ?? UIFont.systemFont(ofSize: 14.0, weight: .regular)
        }
    }
    
}

// MARK: - Debug Helpers -
extension UIFont {
    
    /** For each family, we'll print the family name, then a
     1-tab indented list of each name within the family:
     
     For example:
     
     Futura
        Futura-CondensedExtraBold
        Futura-Medium
        Futura-Bold
        Futura-CondensedMedium
        Futura-MediumItalic
     */
    static func listAllFonts() {
        UIFont.familyNames.forEach { family in
            print(family)
            print("\t\(UIFont.fontNames(forFamilyName: family).joined(separator: "\n\t"))")
        }
    }
}
