//
//  VideoModuleTableViewCell.swift
//  IntermissionApp
//
//  Created by Tom Seymour on 1/21/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

//import UIKit
//import SnapKit
//
//protocol VideoModuleTableViewCellDelegate: class {
//    func videoModuleTableViewCellDidSelect(_ videoModuleTableViewCell: VideoModuleTableViewCell)
//    func videoModuleTableViewCellDidPressCTA(_ videoModuleTableViewCell: VideoModuleTableViewCell)
//}
//
//class VideoModuleTableViewCell: ModuleTableViewCell {
//    weak var delegate: VideoModuleTableViewCellDelegate?
//
//    private let videoImageView: ImageView = {
//        let imageView = ImageView()
//        imageView.contentMode = .scaleAspectFit
//        imageView.clipsToBounds = true
//        return imageView
//    }()
//
//    private let playIconImageView: ImageView = {
//        let imageView = ImageView()
//        imageView.image = UIImage(named: "play_circle")
//        imageView.contentMode = .scaleAspectFit
//        imageView.clipsToBounds = true
//        return imageView
//    }()
//
//    private let titleLabel: Label = {
//        let label = Label()
//        label.numberOfLines = 0
//        return label
//    }()
//
//    private let subtitleImageView: ImageView = {
//        let imageView = ImageView()
//        imageView.image = UIImage(named: "duration_icon")
//        imageView.contentMode = .scaleAspectFit
//        return imageView
//    }()
//
//    private let subtitleLabel: Label = {
//        let label = Label()
//        label.numberOfLines = 1
//        return label
//    }()
//
//    var videoModule: TempVideoModule? {
//        didSet {
//            guard let videoModule = videoModule else { return }
//            self.headingLabel.text = videoModule.headingText
////            self.ctaButton.setTitle(videoModule.ctaText.uppercased(), for: .normal)
//            self.titleLabel.text = videoModule.video.title
//            self.subtitleLabel.text = videoModule.video.time
//        }
//    }
//
//    override func setupViews() {
//        super.setupViews()
//        contentView.addSubview(videoImageView)
//        contentView.addSubview(playIconImageView)
//        contentView.addSubview(titleLabel)
//        contentView.addSubview(subtitleImageView)
//        contentView.addSubview(subtitleLabel)
//
//        [videoImageView, titleLabel, playIconImageView, subtitleLabel, subtitleImageView].forEach {
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleVideoTapped))
//            $0.isUserInteractionEnabled = true
//            $0.addGestureRecognizer(tapGesture)
//        }
//
//    }
//
//    override func setupConstraints() {
//        super.setupConstraints()
//        videoImageView.snp.makeConstraints { make in
//            make.top.equalTo(self.headingLabel.snp.bottom).offset(8)
//            make.leading.trailing.equalToSuperview()
//            make.height.equalTo(self.videoImageView.snp.width).multipliedBy(9.0 / 16.0)
//        }
//        playIconImageView.snp.makeConstraints { make in
//            make.trailing.equalTo(self.videoImageView).offset(-8)
//            make.centerY.equalTo(self.videoImageView.snp.bottom).offset(-8)
//        }
//        subtitleImageView.snp.makeConstraints { make in
//            make.leading.equalTo(self.titleLabel)
//            make.top.bottom.equalTo(self.subtitleLabel)
//        }
//        subtitleLabel.snp.makeConstraints { make in
//            make.top.equalTo(self.videoImageView.snp.bottom).offset(8)
//            make.leading.equalTo(self.subtitleImageView.snp.trailing).offset(4)
//            make.trailing.lessThanOrEqualTo(self.titleLabel)
//        }
//        titleLabel.snp.makeConstraints { make in
//            make.top.equalTo(self.subtitleLabel.snp.bottom).offset(8)
//            make.leading.equalToSuperview().offset(8)
//            make.trailing.equalToSuperview().offset(-8)
//            make.bottom.lessThanOrEqualToSuperview().offset(-16)
//        }
//    }
//
//    @objc
//    private func handleVideoTapped(sender: UITapGestureRecognizer) {
//        delegate?.videoModuleTableViewCellDidSelect(self)
//    }
//
//    override func handleChevronTapped(sender: Button) {
//        delegate?.videoModuleTableViewCellDidPressCTA(self)
//    }
//
//}
