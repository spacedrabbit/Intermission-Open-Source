//
//  Retreat.swift
//  IntermissionApp
//
//  Created by Louis Tur on 2/19/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import Foundation
import Contentful

class Retreat: EntryDecodable, FieldKeysQueryable {
    static let contentTypeId: ContentTypeId = "retreat"
    
    let id: String
    let localeCode: String?
    let updatedAt: Date?
    let createdAt: Date?
    
    let name: String
    let slug: String
    let shareURL: URL
    let displayOrder: Int
    var heroImage: ImageAsset?
    var imageGallery: [ImageAsset] = []
    let price: Double
    let location: String
    let startDate: Date
    let endDate: Date
    var detailSections: [DetailSection] = []
    var retreatPricingOptions: [RetreatPricingOption] = []
    var extendedDetailPages: [RetreatExtendedInfoPage] = []
    var addons: [RetreatAddon] = []
    
    var priceString: String {
        return String(format: "%.2f", price)
    }
    
    required init(from decoder: Decoder) throws {
        let sys = try decoder.sys()
        
        id = sys.id
        localeCode = sys.locale
        updatedAt = sys.updatedAt
        createdAt = sys.createdAt
        
        let fields = try decoder.contentfulFieldsContainer(keyedBy: Retreat.FieldKeys.self)
        
        name = try fields.decode(String.self, forKey: .name)
        slug = try fields.decode(String.self, forKey: .slug)
        shareURL = try fields.decode(URL.self, forKey: .shareURL)
        displayOrder = try fields.decode(Int.self, forKey: .displayOrder)
        price = try fields.decode(Double.self, forKey: .price)
        location = try fields.decode(String.self, forKey: .location)
        startDate = try fields.decode(Date.self, forKey: .startDate)
        endDate = try fields.decode(Date.self, forKey: .endDate)

        try fields.resolveLink(forKey: .heroImage, decoder: decoder, callback: { [weak self] image in
            guard let asset = image as? Asset, let imageAsset = ImageAsset(asset: asset) else { return }
            self?.heroImage = imageAsset
        })
        
        try fields.resolveLinksArray(forKey: .imageGallery, decoder: decoder, callback: { [weak self] images in
            let imageAssets = (images as? [Asset])?
                .compactMap{ $0 }
                .compactMap(ImageAsset.init(asset:))
            guard let images = imageAssets else { return }
            self?.imageGallery = images
        })
        
        try fields.resolveLinksArray(forKey: .detailSections, decoder: decoder, callback: { [weak self] (detailSections) in
            self?.detailSections = (detailSections as? [DetailSection]) ?? []
        })
        
        try fields.resolveLinksArray(forKey: .extendedInfoPage, decoder: decoder, callback: { [weak self] (extendedInfoPages) in
            self?.extendedDetailPages = (extendedInfoPages as? [RetreatExtendedInfoPage]) ?? []
        })
        
        try fields.resolveLinksArray(forKey: .pricingOptions, decoder: decoder, callback: { [weak self] (options) in
            self?.retreatPricingOptions = (options as? [RetreatPricingOption]) ?? []
        })
        
        try fields.resolveLinksArray(forKey: .addons, decoder: decoder, callback: { [weak self] addons in
            self?.addons = (addons as? [RetreatAddon]) ?? []
        })
    }
    
    enum FieldKeys: String, CodingKey {
        case name, slug, price, location, addons
        case shareURL = "share_url"
        case displayOrder = "display_order"
        case startDate = "start_date"
        case endDate = "end_date"
        case heroImage = "hero_image"
        case imageGallery = "image_gallery"
        case pricingOptions = "pricing_options"
        case detailSections = "detail_sections"
        case extendedInfoPage = "extended_info_pages"
    }
}

// MARK: - RetreatPricingOption -
class RetreatPricingOption: EntryDecodable, FieldKeysQueryable {
    static var contentTypeId: ContentTypeId = "retreat_pricing_option"
    
    let id: String
    let localeCode: String?
    let updatedAt: Date?
    let createdAt: Date?
    
    let name: String
    let slug: String
    let price: Double
    let icon: String?
    let helpText: String?
    
    var priceString: String {
        return String(format: "%.2f", price)
    }
    
    var priceLevel: PriceLevel? {
        return PriceLevel(rawValue: icon ?? "")
    }
    
    required init(from decoder: Decoder) throws {
        let sys = try decoder.sys()
        
        id = sys.id
        localeCode = sys.locale
        updatedAt = sys.updatedAt
        createdAt = sys.createdAt
        
        let fields = try decoder.contentfulFieldsContainer(keyedBy: RetreatPricingOption.FieldKeys.self)
        
        name = try fields.decode(String.self, forKey: .name)
        slug = try fields.decode(String.self, forKey: .slug)
        price = try fields.decode(Double.self, forKey: .price)
        icon = try fields.decodeIfPresent(String.self, forKey: .icon)
        helpText = try fields.decodeIfPresent(String.self, forKey: .helpText)
    }
    
    
    enum FieldKeys: String, CodingKey {
        case name = "pricing_option_name"
        case slug = "pricing_option_slug"
        case price, icon
        case helpText = "help_text"
    }
    
    enum PriceLevel: String {
        case low, mid, high
    }
}

/** Represent a single detail cell in the RetreatsDetailPage.
 
 */
class DetailSection: EntryDecodable, FieldKeysQueryable {
    static var contentTypeId: ContentTypeId = "detail_section"
    
    let id: String
    let localeCode: String?
    let updatedAt: Date?
    let createdAt: Date?
    
    let title: String
    let markdownDetails: RichTextDocument?
    let plainTextDetails: String?

    required init(from decoder: Decoder) throws {
        let sys = try decoder.sys()
        
        id = sys.id
        localeCode = sys.locale
        updatedAt = sys.updatedAt
        createdAt = sys.createdAt
        
        let fields = try decoder.contentfulFieldsContainer(keyedBy: DetailSection.FieldKeys.self)
        
        title = try fields.decode(String.self, forKey: .title)
        markdownDetails = try fields.decodeIfPresent(RichTextDocument.self, forKey: .markdownDetails)
        plainTextDetails = try fields.decodeIfPresent(String.self, forKey: .plainTextDetails)
    }

    enum FieldKeys: String, CodingKey {
        case title = "section_title"
        case markdownDetails = "section_markdown_details"
        case plainTextDetails = "section_plain_text_details"
    }
}

/** Exactly the same as DetailSection, but with an optional image gallery. This model was added for content sanitation
 purposes on Contentful -- I needed to control which places an image gallery was acceptable by restricting which type
 of DetailSection could be used.
 
 */
class DetailSectionWithGallery: EntryDecodable, FieldKeysQueryable {
    static var contentTypeId: ContentTypeId = "detail_section_with_gallery"
    
    let id: String
    let localeCode: String?
    let updatedAt: Date?
    let createdAt: Date?
    
    let title: String
    let markdownDetails: RichTextDocument?
    let plainTextDetails: String?
    var imageGallery: [ImageAsset]?
    
    required init(from decoder: Decoder) throws {
        let sys = try decoder.sys()
        
        id = sys.id
        localeCode = sys.locale
        updatedAt = sys.updatedAt
        createdAt = sys.createdAt
        
        let fields = try decoder.contentfulFieldsContainer(keyedBy: DetailSectionWithGallery.FieldKeys.self)
        
        title = try fields.decode(String.self, forKey: .title)
        markdownDetails = try fields.decodeIfPresent(RichTextDocument.self, forKey: .markdownDetails)
        plainTextDetails = try fields.decodeIfPresent(String.self, forKey: .plainTextDetails)
        
        try fields.resolveLinksArray(forKey: .gallery, decoder: decoder, callback: { [weak self] (images) in
            let imageAssets = (images as? [Asset])?
                .compactMap{ $0 }
                .compactMap(ImageAsset.init(asset:))
            guard let images = imageAssets else { return }
            self?.imageGallery = images
        })
    }
    
    enum FieldKeys: String, CodingKey {
        case title = "section_title"
        case markdownDetails = "section_markdown_details"
        case plainTextDetails = "section_plain_text_details"
        case gallery = "gallery"
    }
}

class RetreatExtendedInfoPage: EntryDecodable, FieldKeysQueryable {
    static var contentTypeId: ContentTypeId = "retreat_extended_info_page"
    
    let id: String
    let localeCode: String?
    let updatedAt: Date?
    let createdAt: Date?
    
    let cellTitle: String
    let pageTitle: String
    let pageDetailsMarkdown: RichTextDocument?
    let pageDetailsPlainText: String?
    var pageDetailSections: [DetailSectionWithGallery] = []
    
    required init(from decoder: Decoder) throws {
        let sys = try decoder.sys()
        
        id = sys.id
        localeCode = sys.locale
        updatedAt = sys.updatedAt
        createdAt = sys.createdAt
        
        let fields = try decoder.contentfulFieldsContainer(keyedBy: RetreatExtendedInfoPage.FieldKeys.self)
        
        cellTitle = try fields.decode(String.self, forKey: .cellTitle)
        pageTitle = try fields.decode(String.self, forKey: .pageTitle)
        pageDetailsMarkdown = try fields.decodeIfPresent(RichTextDocument.self, forKey: .pageDetailsMarkdown)
        pageDetailsPlainText = try fields.decodeIfPresent(String.self, forKey: .pageDetailsPlainText)
        
        try fields.resolveLinksArray(forKey: .pageDetailSection, decoder: decoder) { [weak self] (details) in
            self?.pageDetailSections = (details as? [DetailSectionWithGallery]) ?? []
        }
    }
    
    
    enum FieldKeys: String, CodingKey {
        case cellTitle = "link_title"
        case pageTitle = "page_title"
        case pageDetailsMarkdown = "page_details_markdown"
        case pageDetailsPlainText = "page_details_plain_text"
        case pageDetailSection = "detail_sections"
    }
}


