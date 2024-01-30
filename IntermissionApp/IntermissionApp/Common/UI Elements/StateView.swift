//
//  EmptyStateView.swift
//  IntermissionApp
//
//  Created by Tom Seymour on 2/6/19.
//  Copyright © 2019 intermissionsessions. All rights reserved.
//

import UIKit
import SnapKit

protocol StateViewDelegate: class {
    func stateViewDidPressCTA(_ stateView: StateView, for state: StateView.State)
}

class StateView: UIView {
    
    private var imageView: ImageView = {
        let imageView = ImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let textLabel: Label = {
        let label = Label()
        label.numberOfLines = 0
        label.textColor = .darkGray
        return label
    }()
    
    private let ctaButton: Button = {
        let button = Button()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = .cyan
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let container = UIView()
    
    enum State {
        case empty, error
    }
    
    var state: StateView.State {
        didSet {
            configureForState()
        }
    }
    
    weak var delegate: StateViewDelegate?
    
    init(_ state: StateView.State) {
        self.state = state
        super.init(frame: CGRect.zero)
        setupViews()
        setupConstraints()
        configureForState()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .white
        addSubview(container)
        container.addSubview(imageView)
        container.addSubview(textLabel)
        container.addSubview(ctaButton)
        ctaButton.addTarget(self, action: #selector(handleCTATapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(self.imageView.snp.width)
        }
        textLabel.snp.makeConstraints { make in
            make.top.equalTo(self.imageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.75)
        }
        ctaButton.snp.makeConstraints { make in
            make.top.equalTo(self.textLabel.snp.bottom).offset(30)
            make.centerX.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalTo(60)
        }
        container.snp.makeConstraints { make in
            make.centerY.leading.trailing.equalToSuperview()
        }
    }
    
    private func configureForState() {
        switch state {
        case .empty:
            textLabel.text = "You have completed all of your tasks, Copyright © 2019 intermissionsessions. All rights reserved."
            imageView.image = UIImage(named: "emptyState")
            ctaButton.setTitle("Start Exploring".uppercased(), for: .normal)
        case .error:
            textLabel.text = "Whoops! Looks like something went wrong, Copyright © 2019 intermissionsessions. All rights reserved."
            imageView.image = UIImage(named: "errorState")
            ctaButton.setTitle("Retry".uppercased(), for: .normal)
        }
    }
    
    @objc
    private func handleCTATapped() {
        delegate?.stateViewDidPressCTA(self, for: state)
    }
}
