//
//  TwitterUIViewController.swift
//  TwitterUI
//
//  Created by Roman Blum on 07.12.16.
//  Copyright © 2016 RMNBLM. All rights reserved.
//

import UIKit

let offsetHeaderStop: CGFloat = 40.0 // At this offset the Header stops its transformations
let distanceWLabelHeader: CGFloat = 32.0 // The distance between the top of the screen and the top of the White Label

let headerHeight: CGFloat = 107

let avatarOffset: CGFloat = 26
let avatarSize: CGFloat = 69
let avatarCornerRadius: CGFloat = 10
let avatarBorderWidth: CGFloat = 3

let profileHeight: CGFloat = 90
let profileLeftMargin: CGFloat = 16

class TwitterUIViewController: UIViewController, UITableViewDelegate {

    // MARK: Life Cycle
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        UIApplication.shared.statusBarStyle = .lightContent

        let header = tableView.tableHeaderView!
        header.setNeedsLayout()
        header.layoutIfNeeded()

        let height = header.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        var frame = header.frame
        frame.size.height = height
        header.frame = frame

        tableView.tableHeaderView = header
        tableView.contentInset = UIEdgeInsets(top: headerHeight - avatarOffset, left: 0, bottom: tabBarController?.tabBar.bounds.height ?? 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -headerHeight + avatarOffset)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = .all

        setupViews()
        applyConstraints()
    }

    // MARK: UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y + headerView.bounds.height - avatarOffset
        var avatarTransform = CATransform3DIdentity
        var headerTransform = CATransform3DIdentity

        if offset < 0 { // PULL DOWN
            let headerScaleFactor: CGFloat = -(offset) / headerView.bounds.height
            let headerSizevariation = ((headerView.bounds.height * (1.0 + headerScaleFactor)) - headerView.bounds.height)/2

            if headerSizevariation.isNaN {
                return
            }

            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            headerView.layer.zPosition = 0
            headerLabel.isHidden = true
        } else { // SCROLL UP/DOWN
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offsetHeaderStop, -offset), 0)

            headerLabel.isHidden = false
            let alignToNameLabel = -offset + profileLabel.frame.origin.y + headerView.frame.height + offsetHeaderStop

            headerLabel.frame.origin = CGPoint(x: headerLabel.frame.origin.x, y: max(alignToNameLabel, distanceWLabelHeader + offsetHeaderStop))

            headerBlurView.alpha = min (1.0, (offset - alignToNameLabel)/distanceWLabelHeader)

            let avatarScaleFactor = (min(offsetHeaderStop, offset)) / avatarView.bounds.height / 1.4 // Slow down the animation
            let avatarSizeVariation = ((avatarView.bounds.height * (1.0 + avatarScaleFactor)) - avatarView.bounds.height) / 2.0
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0)
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0)

            if offset <= offsetHeaderStop {
                if avatarView.layer.zPosition < headerView.layer.zPosition {
                    headerView.layer.zPosition = 0
                }
            } else {
                if avatarView.layer.zPosition >= headerView.layer.zPosition {
                    headerView.layer.zPosition = 2
                }
            }
        }

        headerView.layer.transform = headerTransform
        avatarView.layer.transform = avatarTransform
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: headerView.frame.maxY, left: 0, bottom: tabBarController?.tabBar.bounds.height ?? 0, right: 0)
    }

    // MARK: Refresh Control Selector
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.forceRefresh()
        })
    }

    func forceRefresh() {
        refreshControl.endRefreshing()
    }

    // MARK: Public Properties
    var heroTitle: String = "" {
        didSet {
            headerLabel.text = heroTitle
            profileLabel.text = heroTitle
        }
    }

    // MARK: Views and Constraints
    private func setupViews() {
        headerView.addSubview(headerImageView)
        headerView.addSubview(headerBlurView)
        headerView.addSubview(headerLabel)

        profileView.addSubview(avatarView)
        profileView.addSubview(profileLabel)

        tableView.addSubview(refreshControl)
        tableView.tableHeaderView = profileView

        avatarView.addSubview(avatarImageView)

        avatarImageView.backgroundColor = UIColor.gray
        headerImageView.backgroundColor = UIColor.lightGray

        headerLabel.text = heroTitle
        profileLabel.text = heroTitle

        view.addSubview(headerView)
        view.addSubview(tableView)
    }

    private func applyConstraints() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: headerHeight).isActive = true

        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: headerHeight).isActive = true

        headerImageView.translatesAutoresizingMaskIntoConstraints = false
        headerImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        headerImageView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
        headerImageView.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        headerImageView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true

        headerBlurView.translatesAutoresizingMaskIntoConstraints = false
        headerBlurView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        headerBlurView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
        headerBlurView.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        headerBlurView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        profileView.translatesAutoresizingMaskIntoConstraints = false
        profileView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor).isActive = true
        profileView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor).isActive = true
        profileView.heightAnchor.constraint(equalToConstant: profileHeight + avatarOffset).isActive = true
        profileView.widthAnchor.constraint(equalTo: tableView.widthAnchor).isActive = true

        profileLabel.translatesAutoresizingMaskIntoConstraints = false
        profileLabel.leftAnchor.constraint(equalTo: profileView.leftAnchor, constant: profileLeftMargin).isActive = true
        profileLabel.rightAnchor.constraint(equalTo: profileView.rightAnchor, constant: profileLeftMargin).isActive = true
        profileLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8).isActive = true

        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.leftAnchor.constraint(equalTo: profileView.leftAnchor, constant: profileLeftMargin).isActive = true
        avatarView.heightAnchor.constraint(equalToConstant: avatarSize).isActive = true
        avatarView.widthAnchor.constraint(equalToConstant: avatarSize).isActive = true

        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.leadingAnchor.constraint(equalTo: avatarView.leadingAnchor, constant: avatarBorderWidth).isActive = true
        avatarImageView.trailingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: -avatarBorderWidth).isActive = true
        avatarImageView.topAnchor.constraint(equalTo: avatarView.topAnchor, constant: avatarBorderWidth).isActive = true
        avatarImageView.bottomAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: -avatarBorderWidth).isActive = true
    }

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.bounds.origin.y = -headerHeight / 2
        control.tintColor = UIColor.white
        control.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        return control
    }()

    private let headerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = UIColor.lightGray
        return view
    }()

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = false
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .center
        return label
    }()

    let headerImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = UIViewContentMode.scaleAspectFill
        return view
    }()

    private let headerBlurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)

        let vibrancy = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancy)
        vibrancyView.frame = blurView.bounds
        vibrancyView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.contentView.addSubview(vibrancyView)
        blurView.alpha = 0.0

        return blurView
    }()

    private(set) lazy var tableView: UITableView = {
        let view = UITableView()
        view.bounces = true
        view.clipsToBounds = true
        view.backgroundColor = UIColor.clear
        view.tableFooterView = UIView()
        view.delegate = self
        return view
    }()

    private let profileView = UIView()

    private let avatarView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = avatarCornerRadius
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = avatarBorderWidth
        return view
    }()

    let avatarImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = UIColor.lightGray
        view.layer.cornerRadius = avatarCornerRadius
        view.layer.borderColor = UIColor.white.cgColor
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()

    private let profileLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }()
}
