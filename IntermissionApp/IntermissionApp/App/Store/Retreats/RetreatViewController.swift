//
//  RDPViewController.swift
//  IntermissionApp
//
//  Created by Harichandan Singh on 3/3/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SnapKit
import SwiftRichString

// MARK: - RDPViewController -

/** "Retreat Details View Controller" (RDP)
 Table view to display information about a Retreat and it's Addons
 */
class RetreatViewController: TableViewController {
    private let retreat: Retreat
    private let user: User?
    private let guest: GuestUser?
    
    private var sections: [[RetreatItem]] = [
        [.hero, .heading, .border],
        [], // detail sections, multiple
        [], // extended info sections, multiple
        [], // price options, multiple
        [.helper]
    ]
    private struct ReuseIdentifier {
        static let hero = "heroCellIdentifier"
        static let heading = "headingCellIdentifier"
        static let border = "waveBorderCellIdentifier"
        static let detailSection = "detailSectionCellIdentifier"
        static let pricingOptions = "pricingOptionCellIdentifier"
        static let extendedDetails = "extendedDetailsCellIdentifier"
        static let sectionHeader = "sectionHeaderViewIdentifier"
        static let helperText = "helperTextCellIdentifier"
    }
    
    private let cartButton: Button = {
        let button = Button()
        button.frame = CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0)
        button.setImage(Icon.NavBar.cartFilledLight.image, for: .normal)
        button.setImage(Icon.NavBar.cartFilledDark.image, for: .highlighted)
        return button
    }()
    
    private let shareButton: Button = {
        let button = Button()
        button.frame = CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0)
        button.setImage(Icon.NavBar.shareFilledLight.image, for: .normal)
        button.setImage(Icon.NavBar.shareFilledDark.image, for: .highlighted)
        return button
    }()
    
    private let footerView = AddToCardFooterView()
    
    // MARK: - Initializers -
    
    init(with retreat: Retreat, user: User?) {
        self.retreat = retreat
        self.user = user
        self.guest = nil
        super.init(nibName: nil, bundle: nil)
        
        commonInit()
    }
    
    // TODO: add a banner header informing of guest status!
    init(with retreat: Retreat, guestUser: GuestUser?) {
        self.retreat = retreat
        self.user = nil
        self.guest = guestUser
        super.init(nibName: nil, bundle: nil)
        
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        sections[1] = Array(repeating: RetreatItem.detailSection, count: self.retreat.detailSections.count)
        sections[2] = Array(repeating: RetreatItem.extendedInfoSection, count: self.retreat.extendedDetailPages.count)
        sections[3] = Array(repeating: RetreatItem.priceOptions, count: self.retreat.retreatPricingOptions.count)
        
        self.delegate = self
        self.isNavigationBarHidden = true
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.hidesBottomBarWhenPushed = true
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Common setup
        self.tableView.backgroundView = UIView()
        self.tableView.backgroundView?.backgroundColor = .paleLavendar
        
        self.tableView.estimatedRowHeight = 375.0
        self.tableView.rowHeight = UITableView.automaticDimension

        let navButtons = Flags.shouldDisplayShop ? [cartButton, shareButton] : [shareButton]
        self.navigationItem.rightNavigationButtons = navButtons

        // Button Actions
        shareButton.addTarget(self, action: #selector(handleShareTapped(sender:)), for: .touchUpInside)
        cartButton.addTarget(self, action: #selector(handleCartTapped(sender:)), for: .touchUpInside)
        
        // Layout
        if Flags.shouldDisplayShop {
            self.view.addSubview(footerView)
            footerView.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
        
        // Cell Registering
        self.tableView.register(GalleryTableCell.self, forCellReuseIdentifier: ReuseIdentifier.hero)
        self.tableView.register(RetreatHeaderCell.self, forCellReuseIdentifier: ReuseIdentifier.heading)
        self.tableView.register(RetreatDetailCell.self, forCellReuseIdentifier: ReuseIdentifier.detailSection)
        self.tableView.register(BorderCell.self, forCellReuseIdentifier: ReuseIdentifier.border)
        self.tableView.register(RetreatPricingOptionCell.self, forCellReuseIdentifier: ReuseIdentifier.pricingOptions)
        self.tableView.register(SettingsCell.self, forCellReuseIdentifier: ReuseIdentifier.extendedDetails)
        self.tableView.register(DashboardHelperTextCell.self, forCellReuseIdentifier: ReuseIdentifier.helperText)
        
        self.tableView.register(RetreatDetailsReuseableHeader.self, forHeaderFooterViewReuseIdentifier: ReuseIdentifier.sectionHeader)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let bottomInset = Flags.shouldDisplayShop ? footerView.h : self.view.safeAreaInsets.bottom
        tableView.contentInset = UIEdgeInsets(top: tableView.contentInset.top, left: 0.0,
                                              bottom: bottomInset, right: 0.0)
    }
    
    // MARK: - Events -
    
    @objc
    private func handleCartTapped(sender: Button) {
        self.ia_presentAlert(with: "The Cart!", message: "You've selected to view your cart. But we don't yet have this feature implemented. Come back later and check in on our progress 🤓")
    }
    
    @objc
    private func handleShareTapped(sender: Button) {
        let activityController = UIActivityViewController(activityItems: [retreat.shareURL], applicationActivities: nil)
        activityController.excludedActivityTypes = [.addToReadingList, .assignToContact, .openInIBooks,
                                                    .postToFlickr, .postToTencentWeibo, .postToWeibo,
                                                    .postToVimeo, .print, .saveToCameraRoll, .markupAsPDF]
        activityController.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, complete: Bool, _, error: Error?) in
            if let e = error {
                self.presentAlert(with: "Couldn't Share", message: e.localizedDescription)
                return
            }
            
            print("finished")
        }
        
        self.present(activityController, animated: true, completion: nil)
    }
}

// MARK: - RetreatItem -

private enum RetreatItem {
    case hero, heading, border, detailSection, priceOptions,
    extendedInfoSection, helper
}

// MARK: - UITableViewDelegate, UITableViewDataSource -

extension RetreatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = sections[indexPath.section][indexPath.row]
        
        switch item {
        case .hero:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.hero) as! GalleryTableCell
            cell.configure(with: retreat)
            cell.cellDelegate = self
            
            return cell
        case .heading:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.heading) as! RetreatHeaderCell
            cell.configure(with: retreat)
            
            return cell
            
        case .border:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.border, for: indexPath) as! BorderCell
            cell.configure(with: .whiteBottom)
            
            return cell
            
        case .detailSection:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.detailSection, for: indexPath) as! RetreatDetailCell
            cell.configure(with: retreat.detailSections[indexPath.row])
            
            return cell
            
        case .extendedInfoSection:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.extendedDetails, for: indexPath) as! SettingsCell
            let extendedInfo = retreat.extendedDetailPages[indexPath.row]
            cell.configure(with: extendedInfo.cellTitle, leftAccessory: nil, rightAccessory: .chevron)
            
            return cell
            
        case .priceOptions:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.pricingOptions, for: indexPath) as! RetreatPricingOptionCell
            let option = retreat.retreatPricingOptions[indexPath.row]
            cell.configure(with: option)
            
            return cell
            
        case .helper:
            // Right now there's only the 1, so this is fine. But will need to be better with identifiers
            // if we end up adding more of these helper text cells
            let cell = tableView.dequeueReusableCell(withIdentifier: ReuseIdentifier.helperText, for: indexPath) as! DashboardHelperTextCell
            cell.configure(with: .retreatPrices)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = sections[indexPath.section][indexPath.row]
        
        switch item {
        case .hero:
            return tableView.w
        case .heading:
            return UITableView.automaticDimension
        case .border:
            return UITableView.automaticDimension
        case .detailSection:
            return UITableView.automaticDimension
        case .priceOptions:
            return RetreatPricingOptionCell.height
        case .extendedInfoSection:
            return SettingsCell.height
        case .helper:
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = sections[indexPath.section][indexPath.row]
        
        guard
            item == .extendedInfoSection,
            retreat.extendedDetailPages.count >= indexPath.row + 1
        else { return }
        
        let dtvc = RetreatExtendedInfoVC(infoPage: retreat.extendedDetailPages[indexPath.row])
        self.navigationController?.pushViewController(dtvc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section > 1 else { return nil }
        
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: ReuseIdentifier.sectionHeader) as! RetreatDetailsReuseableHeader
        
        if section == 2 {
            view.configure(with: "Additional Info")
        } else if section == 3 {
            view.configure(with: "Accomodation Prices")
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section > 1 else { return 0.0 }
        return RetreatDetailsReuseableHeader.height
    }
}

// MARK: - GalleryViewControllerDelegate -

extension RetreatViewController: GalleryViewControllerDelegate {
    
    func galleryViewController(_ galleryViewController: GalleryViewController, didUpdateIndex index: Int) {
        guard let galleryCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? GalleryTableCell else { return }
        galleryCell.setPage(index: index)
    }
    
}

// MARK: - GalleryTableCellDelegate -

extension RetreatViewController: GalleryTableCellDelegate {
    
    func galleryTableCellWasTapped(_ galleryTableCell: GalleryTableCell) {
        let urls = ([retreat.heroImage?.url] + retreat.imageGallery.map { $0.url }).compactMap { $0 }
        let vc = GalleryViewController(urls: urls, selectedIndex: galleryTableCell.currentIndex)
        vc.galleryDelegate = self

        let navController = NavigationController(rootViewController: vc)
        self.present(navController, transition: Transition())
    }
    
}

// MARK: - RetreatDetailsReuseableHeader -

/// Simple headerview with a single label in the same styling as the H3 tag on the markdown cells
fileprivate class RetreatDetailsReuseableHeader: UITableViewHeaderFooterView {
    
    private let tagLabel: Label = {
        let label = Label()
        label.style = Styles.styles[Font.retreatDetailSectionTitle]
        return label
    }()
    
    // MARK: - Initializers
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(tagLabel)
        
        // Yes, this is needed...ffs
        self.backgroundView = UIView()
        self.backgroundView?.backgroundColor = .white
        self.backgroundColor = .white
        self.contentView.backgroundColor = UIColor.white
        
        tagLabel.safelyEnforceSizeOnAutoLayout()
        
        tagLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20.0)
            make.bottom.equalToSuperview().inset(8.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure -
    
    func configure(with title: String) {
        tagLabel.styledText = title

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    // MARK: - Height -
    
    class var height: CGFloat {
        return 60.0
    }
}
