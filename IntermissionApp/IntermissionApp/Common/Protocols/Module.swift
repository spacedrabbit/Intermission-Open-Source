//
//  Module.swift
//  IntermissionApp
//
//  Created by Louis Tur on 1/21/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit

struct Tab {
    
    enum View: String {
       case home, feed, shop, profile
    }
    
    enum Subview: String {
        case history, discover, favorites, awards, vdp, list, merch, retreat, stats, journey, settings
    }
    
    let icon: UIImage
    let title: String
    let type: View
}

struct Route {
    let tab: Tab.View
    let view: Tab.Subview
    
    static func valid(view: Tab.Subview, for tab: Tab.View) -> Bool {
        switch tab {
        case .home: return [Tab.Subview.history, Tab.Subview.favorites].contains(view)
        case .feed: return [Tab.Subview.discover, Tab.Subview.list].contains(view)
        case .shop: return [Tab.Subview.merch, Tab.Subview.retreat].contains(view)
        case .profile: return [Tab.Subview.stats, Tab.Subview.journey, Tab.Subview.settings].contains(view)
        }
    }
}

struct ModuleCTA {
    let text: String
    let route: Route
}

//struct ModuleArrangement {
//    let allowsHorizontalScroll: Bool
//    let rows: Int
//    let columns: Int
//    let paged: Bool
//    let fullWidth: Bool
//
//    var isGrid: Bool { return rows > 1 && columns > 1 }
//}

/// Represents a single entity to be displayed in a module cell, e.g. a Video
protocol ModuleDisplayable {
    var displayImage: UIImage? { get }
    var displayImageURL: URL? { get }
    var titleText: String? { get }
    var subtitleText: String? { get }
}

/// Represents the contents of a module (cell)
class Module<Component: ModuleDisplayable> {
    var title: String = ""
    var cta: ModuleCTA? = nil
    var components: [Component] = []
}

class VideoModule: Module<Video> {}

class DashboardLayout {
    let title: String
    let navTitle: String?
    let modules: [VideoModule]
    
    init(title: String, navTitle: String?, modules: [VideoModule]) {
        self.title = title
        self.navTitle = navTitle
        self.modules = modules
    }
}

extension Author: ModuleDisplayable {
    
    var displayImage: UIImage? { return nil }
    var displayImageURL: URL? { return self.image?.url }
    var titleText: String? { return self.name }
    var subtitleText: String? { return self.email }
    
}
