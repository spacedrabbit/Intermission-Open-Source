//
//  ImageReferences.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/29/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

enum TabIcon {
    case dashboard, feed, store, profile
    
    var inactive: UIImage? {
        switch self {
        case .dashboard: return UIImage(named: "home_tab")
        case .feed: return UIImage(named: "feed_tab")
        case .store: return UIImage(named: "shop_tab")
        case .profile: return UIImage(named: "profile_tab")
        }
    }
    
    var active: UIImage? {
        switch self {
        case .dashboard: return UIImage(named: "home_tab_active")
        case .feed: return UIImage(named: "feed_tab_active")
        case .store: return UIImage(named: "shop_tab_active")
        case .profile: return UIImage(named: "profile_tab_active")
        }
    }
}

enum ProfileIcon {
    case calendar, clock, play, openCircle, avatar, add, edit
    case guest1, guest2, guest3
    
    var image: UIImage? {
        switch self {
        case .calendar:  return UIImage(named:"calendar_icon_outline")
        case .clock: return UIImage(named:"clock_icon_outline")
        case .play: return UIImage(named:"play_icon_outline")
        case .openCircle: return UIImage(named:"circle_teal_outline")
        case .avatar: return UIImage(named: "avatar_empty")
        case .add: return UIImage(named: "add_filled")
        case .edit: return UIImage(named: "edit_filled")
        case .guest1: return UIImage(named: "guest_profile_icon_1")
        case .guest2: return UIImage(named: "guest_profile_icon_2")
        case .guest3: return UIImage(named: "guest_profile_icon_3")
        }
    }
    
    var highlightedImage: UIImage? {
        switch self {
        case .calendar:  return UIImage(named:"calendar_icon_outline_highlighted")
        case .clock: return UIImage(named:"clock_icon_outline_highlighted")
        case .play: return UIImage(named:"play_icon_outline_highlighted")
        case .openCircle: return UIImage(named:"circle_teal_outline_highlighted")
        case .avatar: return UIImage(named: "avatar_empty_highlighted")
        case .add: return UIImage(named: "add_filled_highlighted")
        case .edit: return UIImage(named: "edit_filled_highlighted")
        case .guest1, .guest2, .guest3: return nil
        }
    }
}

enum Logo {
    case black, placeholder
    
    var image: UIImage? {
        switch self {
        case .black: return UIImage(named: "intermission_logo_black")
        case .placeholder: return UIImage(named: "placeholder_image")
        }
    }
}

struct Decorative {
    
    enum Yogi {
        case yogiBackBend, yogiBackBendTranslucent,
        yogiWarrior2, yogiWarrior2Small, yogiWarrior2NoBkgd, yogaWarrior2LargeRightAligned,
        yogaBackgroundBlob,
        yogiSeatedLegPullRed, yogiSeatedLegPullNoBkdg, yogiSeatedLegPullCTA,
        yogiLongCrow, yogiLongCrowNoBkgd,
        standingPlant
        
        var image: UIImage? {
            switch self {
            case .yogiBackBend: return UIImage(named: "standing_back_bed_yogi")
            case .yogiBackBendTranslucent: return UIImage(named: "yogi_backbend_translucent_bkgd")
            case .yogiWarrior2: return UIImage(named: "warrior_2_w-background")
            case .yogiWarrior2Small: return UIImage(named: "warrior_2_w-background_small")
            case .yogiWarrior2NoBkgd: return UIImage(named: "warrior_2_yogi")
            case .yogaBackgroundBlob: return UIImage(named: "yoga_background")
            case .yogaWarrior2LargeRightAligned: return UIImage(named: "warrior-2-large-right-aligned")
            case .yogiSeatedLegPullRed: return UIImage(named: "yogi_seated_pulled_back_leg_with_bkgd")
            case .yogiSeatedLegPullNoBkdg: return UIImage(named: "yogi_seated_pulled_back_leg")
            case .yogiSeatedLegPullCTA: return UIImage(named: "yogi_seated_pulled_back_leg_on_palette")
            case .yogiLongCrow: return UIImage(named: "long_legged_crow_fitted_width")
            case .yogiLongCrowNoBkgd: return UIImage(named: "long_legged_crow")
            case .standingPlant: return UIImage(named: "standing_plant")
            }
        }
    }
    
    enum Wave {
        case lightWaveBottom, greenWave, lightWaveTop,
        lavendarWaveTopCap, lavendarWaveBottomCap,
        sectionHeader
        
        var image: UIImage? {
            switch self {
            case .lightWaveBottom: return UIImage(named: "wave")
            case .lightWaveTop: return UIImage(named: "login_curved_header")
            case .greenWave: return UIImage(named: "green_wave_top")
            case .lavendarWaveTopCap: return UIImage(named: "lavendar_wave_top_cap")
            case .lavendarWaveBottomCap: return UIImage(named: "lavendar_wave_bottom_cap")
            case .sectionHeader: return UIImage(named: "section_header_wave")
            }
        }
    }
}

struct Onboarding {
    
    enum People {
        case mel, el
        
        var image: UIImage? {
            switch self {
            case .mel: return UIImage(named: "mel")
            case .el: return UIImage(named: "el")
            }
        }
    }
    
    enum Yogi {
        case left, middle, right
        
        var image: UIImage? {
            switch self {
            case .left: return UIImage(named: "left-yogi-onboard")
            case .middle: return UIImage(named: "mid-yogi-onboard")
            case .right: return UIImage(named: "right-yogi-onboard")
            }
        }
    }
    
    enum Other {
        case waveBorder, profileUpload, leftWave, middleWave, rightWave
        
        var image: UIImage? {
            switch self {
            case .waveBorder: return UIImage(named: "onboarding_curve")
            case .profileUpload: return UIImage(named: "profile_image_upload")
            case .leftWave: return UIImage(named: "onboarding_curve_left")
            case .middleWave: return UIImage(named: "onboarding_curve_mid")
            case .rightWave: return UIImage(named: "onboarding_curve_right")
            }
        }
        
        var highlightImage: UIImage? {
            switch self {
            case .profileUpload: return UIImage(named: "profile_image_upload_highlighted")
            default: return nil
            }
        }
    }

}

struct Icon {
    
    enum Facebook {
        case facebook
        
        var image: UIImage? {
            switch self {
            case .facebook: return UIImage(named: "facebook_logo_blue")
            }
        }
    }
    
    enum Social {
        case facebook, twitter, instagram, github, website
        
        var image: UIImage? {
            switch self {
            case .facebook: return UIImage(named: "facebook_dark")
            case .github: return UIImage(named: "github_dark")
            case .twitter: return UIImage(named: "twitter_dark")
            case .instagram: return UIImage(named: "instagram_dark")
            case .website: return UIImage(named: "website_dark")
            }
        }
        
        var highlightImage: UIImage? {
            switch self {
            case .facebook: return UIImage(named: "facebook_cta")
            case .github: return UIImage(named: "github_cta")
            case .twitter: return UIImage(named: "twitter_cta")
            case .instagram: return UIImage(named: "instagram_cta")
            case .website: return UIImage(named: "website_cta")
            }
        }
        
        var lightImage: UIImage? {
            switch self {
            case .facebook, .twitter, .instagram, .website: return nil
            case .github: return UIImage(named: "github_white")
            }
        }
    }
    
    enum History {
        case light, dark
        
        var image: UIImage? {
            switch self {
            case .light: return UIImage(named: "history_icon_light")
            case .dark: return UIImage(named: "history_icon_dark")
            }
        }
    }
    
    enum Stats {
        case playOutline, calendar, timer, star, heart, history
        
        var image: UIImage? {
            switch self {
            case .playOutline: return UIImage(named: "play_icon_outline_teal")
            case .calendar: return UIImage(named: "calendar_icon_outline")
            case .timer: return UIImage(named: "clock_icon_outline")
            case .star: return UIImage(named: "star_outline_teal")
            case .heart: return UIImage(named: "heart_outline_teal")
            case .history: return UIImage(named: "rewatch_outline_teal")
            }
        }
        
        var highlightImage: UIImage? {
            switch self {
            case .playOutline: return UIImage(named: "play_icon_outline_highlighted")
            case .calendar: return UIImage(named: "calendar_icon_outline_highlighted")
            case .timer: return UIImage(named: "clock_icon_outline_highlighted")
            case .star: return UIImage(named: "star_outline_highlighted")
            case .heart: return UIImage(named: "heart_outline_highlighted")
            case .history: return UIImage(named: "rewatch_outline_highlighted")
            }
        }
    }
    
    enum Checkmark {
        case light, dark, cta, accent
        
        var image: UIImage? {
            switch self {
            case .light:  return UIImage(named: "checkmark_white")
            case .dark: return UIImage(named: "checkmark_dark")
            case .cta: return UIImage(named: "checkmark_cta")
            case .accent: return UIImage(named: "checkmark_accent")
            }
        }
    }
    
    enum Duration {
        case light
        
        var image: UIImage? {
            switch self {
            case .light: return UIImage(named: "duration_icon")
            }
        }
    }
    
    enum Chevron {
        case backDark, backLight, backCTA,
            forwardDark, forwardLight,
            downDark, downLight,
            upDark, upLight,
            backFilledDark, backFilledLight, backFilledAccent, backFilledCTA
        
        var image: UIImage? {
            switch self {
            case .backDark: return UIImage(named: "chevron_back_dark")
            case .backLight: return UIImage(named: "chevron_back_light")
            case .backCTA: return UIImage(named: "back_chevron_cta")

            case .forwardDark: return UIImage(named: "chevron_forward_dark")
            case .forwardLight: return UIImage(named: "chevron_forward_light")
                
            case .downDark: return UIImage(named: "chevron_down_dark")
            case .downLight: return UIImage(named: "chevron_down_light")
                
            case .upDark: return UIImage(named: "chevron_up_dark")
            case .upLight: return UIImage(named: "chevron_up_light")

            case .backFilledDark: return UIImage(named: "back_chevron_filled_dark")
            case .backFilledLight: return UIImage(named: "back_chevron_filled_light")
            case .backFilledAccent: return UIImage(named: "back_chevron_filled_accent")
            case .backFilledCTA: return UIImage(named: "back_chevron_filled_cta")
            }
        }
    }
    
    enum NavBar {
        case cartDark, cartLight,
        cartFilledAccent, cartFilledCTA, cartFilledDark, cartFilledLight,
        shareDark, shareLight,
        shareFilledAccent, shareFilledCTA, shareFilledDark, shareFilledLight,
        filter, filterActive, settings, settingsActive,
        xCloseFilledLight, xCloseFilledDark, xCloseFilledCTA, xCloseFilledAccent,
        xClose, xCloseHighlighted
        
        var image: UIImage? {
            switch self {
            case .cartDark: return UIImage(named: "cart_icon_dark")
            case .cartLight: return UIImage(named: "cart_icon_light")
                
            case .cartFilledAccent: return UIImage(named: "cart_filled_accent")
            case .cartFilledCTA: return UIImage(named: "cart_filled_cta")
            case .cartFilledDark: return UIImage(named: "cart_filled_dark")
            case .cartFilledLight: return UIImage(named: "cart_filled_light")
                
            case .shareDark: return UIImage(named: "share_icon_dark")
            case .shareLight: return UIImage(named: "share_icon_light")
                
            case .shareFilledAccent: return UIImage(named: "share_filled_accent")
            case .shareFilledCTA: return UIImage(named: "share_filled_cta")
            case .shareFilledDark: return UIImage(named: "share_filled_dark")
            case .shareFilledLight: return UIImage(named: "share_filled_light")
                
            case .filter: return UIImage(named: "filter")
            case .filterActive: return UIImage(named: "filter_active")
    
            case .settings: return UIImage(named: "settings")
            case .settingsActive: return UIImage(named: "settings_highlighted")
                
            case .xCloseFilledLight: return UIImage(named: "close_filled_light")
            case .xCloseFilledDark: return UIImage(named: "close_filled_dark")
            case .xCloseFilledCTA: return UIImage(named: "close_filled_cta")
            case .xCloseFilledAccent: return UIImage(named: "close_filled_accent")
                
            case .xClose: return UIImage(named: "close_dark")
            case .xCloseHighlighted: return UIImage(named: "close_highlighted")
            }
        }
    }
    
    enum Hearts {
        case filledAccent, filledCTA, filledDark, filledLight,
        filledHeartedAccent, filledHeartedCTA, filledHeartedDark, filledHeartedLight,
        outlineDark, outlineLight, outlineFilledRed, outlineFilledWhite, outlineFilledDark
        
        var image: UIImage? {
            switch self {
            case .filledAccent: return UIImage(named: "heart_filled_accent")
            case .filledCTA: return UIImage(named: "heart_filled_cta")
            case .filledDark: return UIImage(named: "heart_filled_dark")
            case .filledLight: return UIImage(named: "heart_filled_light")
                
            case .filledHeartedAccent: return UIImage(named: "heart_hearted_filled_accent")
            case .filledHeartedCTA: return UIImage(named: "heart_hearted_filled_cta")
            case .filledHeartedDark: return UIImage(named: "heart_hearted_filled_dark")
            case .filledHeartedLight: return UIImage(named: "heart_hearted_filled_light")
                
            case .outlineDark: return UIImage(named: "heart_icon_dark")
            case .outlineLight: return UIImage(named: "heart_icon_light")
                
            case .outlineFilledRed: return UIImage(named: "heart_icon_filled_red")
            case .outlineFilledWhite: return UIImage(named: "heart_icon_filled_white")
            case .outlineFilledDark: return UIImage(named: "heart_icon_filled_dark")
            }
        }
    }
    
    enum Play {
        case outlineLight, outlineDark, filledClear, filledCTA, filledDark, filledWhite
        
        var image: UIImage? {
            switch self {
            case .outlineLight:  return UIImage(named: "play_icon_outline_light")
            case .outlineDark: return UIImage(named: "play_icon_outline_dark")
                
            case .filledClear: return UIImage(named: "play_icon_filled_clear")
            case .filledCTA: return UIImage(named: "play_icon_filled_cta")
            case .filledDark: return UIImage(named: "play_icon_filled_dark")
            case .filledWhite: return UIImage(named: "play_icon_filled_white")
            }
        }
    }
    
    enum Reload {
        case normal, highlighted
        
        var image: UIImage? {
            switch self {
            case .normal: return UIImage(named: "reload")
            case .highlighted: return UIImage(named: "reload_highlighted")
            }
        }
    }
    
    enum Retreat {
        case low, mid, high
        
        var image: UIImage? {
            switch self {
            case .low: return UIImage(named: "low_tier_yogi")
            case .mid: return UIImage(named: "mid_tier_yogi")
            case .high: return UIImage(named: "high_tier_yogi")
            }
        }
    }
}
