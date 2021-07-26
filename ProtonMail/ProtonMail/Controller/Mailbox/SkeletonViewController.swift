//
//  SkeletonViewController.swift
//  ProtonMail - Created on 8/16/15.
//
//
//  Copyright (c) 2019 Proton Technologies AG
//
//  This file is part of ProtonMail.
//
//  ProtonMail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonMail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonMail.  If not, see <https://www.gnu.org/licenses/>.

import SkeletonView
import ProtonCore_UIFoundations
import UIKit

class SkeletonViewController: ProtonMailTableViewController {
    
    private(set) var timeout: Int = 10
    private(set) var timer: Timer?
    
    class func instance(timeout: Int = 10) -> SkeletonViewController {
        let skeletonVC = SkeletonViewController(style: .plain)
        skeletonVC.timeout = timeout
        let _ = UINavigationController(rootViewController: skeletonVC)
        return skeletonVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.isScrollEnabled = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.separatorColor = UIColorManager.InteractionWeak
        self.tableView.RegisterCell(MailBoxSkeletonLoadingCell.Constant.identifier)
        
        self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(self.timeout), repeats: false) { _ in
            NotificationCenter.default.post(name: .switchView, object: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 13.0, *) {
            self.view.window?.windowScene?.title = LocalString._locations_inbox_title
        }
        self.title = LocalString._locations_inbox_title
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.timer?.invalidate()
        self.timer = nil
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = MailBoxSkeletonLoadingCell.Constant.identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.showAnimatedGradientSkeleton()
        return cell
    }
}