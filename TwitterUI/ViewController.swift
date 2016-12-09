//
//  ViewController.swift
//  TwitterUI
//
//  Created by Roman Blum on 07.12.16.
//  Copyright © 2016 RMNBLM. All rights reserved.
//

import UIKit

class ViewController: TwitterUIViewController, UITableViewDataSource {

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        heroTitle = "Christian Bale"
        avatarImageView.image = UIImage(named: "avatar")
        headerImageView.image = UIImage(named: "header")

        tableView.dataSource = self
    }

    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 40
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "Tweet Tweet!"
        return cell
    }
}

