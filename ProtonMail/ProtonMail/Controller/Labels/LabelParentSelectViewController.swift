//
//  LabelParentSelectViewController.swift
//  ProtonMail
//
//
//  Copyright (c) 2021 Proton Technologies AG
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

import ProtonCore_UIFoundations
import UIKit

final class LabelParentSelectViewController: ProtonMailViewController {

    @IBOutlet private var tableView: UITableView!
    private var viewModel: LabelParentSelctVMProtocol!

    static func instance(hasNavigation: Bool = true) -> LabelParentSelectViewController {
        let board = UIStoryboard.Storyboard.inbox.storyboard
        let identifier = "LabelParentSelectViewController"
        guard let instance = board
                .instantiateViewController(withIdentifier: identifier) as? LabelParentSelectViewController else {
            return .init()
        }
        if hasNavigation {
            _ = UINavigationController(rootViewController: instance)
        }
        return instance
    }

    func set(viewModel: LabelParentSelctVMProtocol) {
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        assert(self.viewModel != nil, "Plese use set(viewModel:) to setting")

        self.setupView()
    }

    private func setupView() {
        self.setupNavigationBar()
        self.setupTable()
    }

    private func setupNavigationBar() {
        self.title = LocalString._parent_folder

        let btn = UIBarButtonItem(title: LocalString._general_done_button,
                                  style: .plain,
                                  target: self,
                                  action: #selector(self.clickDoneButton))
        var attr = FontManager.HeadlineSmall
        attr[.foregroundColor] = UIColorManager.InteractionNorm
        btn.setTitleTextAttributes(attr, for: .normal)
        self.navigationItem.rightBarButtonItem = btn
    }

    private func setupTable() {
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.register(MenuItemTableViewCell.defaultNib(),
                                forCellReuseIdentifier: MenuItemTableViewCell.defaultID())
        self.tableView.register(UITableViewCell.self)
    }

    @objc
    private func clickDoneButton() {
        self.viewModel.finishSelect()
        self.navigationController?.popViewController(animated: true)
    }
}

extension LabelParentSelectViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.labels.getNumberOfRows() + 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return self.setupNoneCell(indexPath: indexPath)
        }
        return self.setupFolderCell(indexPath: indexPath)
    }

    private func setupNoneCell(indexPath: IndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }

        guard let cellInstance = cell else { return .init() }

        cellInstance.textLabel?.text = LocalString._general_none
        cellInstance.textLabel?.textColor = UIColorManager.TextNorm
        cellInstance.accessoryType = self.viewModel.parentID.isEmpty ? .checkmark: .none
        cellInstance.selectionStyle = .none
        cellInstance.addSeparator(padding: 0)
        return cellInstance
    }

    private func setupFolderCell(indexPath: IndexPath) -> MenuItemTableViewCell {
        guard let cell = self.tableView
                .dequeueReusableCell(withIdentifier: MenuItemTableViewCell.defaultID(),
                                     for: indexPath) as? MenuItemTableViewCell else {
            return .init()
        }
        let path = IndexPath(row: indexPath.row - 1, section: 0)
        guard let label = self.viewModel.labels.getFolderItem(by: path) else {
            return .init()
        }
        cell.config(by: label, showArrow: false, useFillIcon: self.viewModel.useFolderColor, delegate: nil)
        if self.viewModel.isAllowToSelect(row: indexPath.row) {
            cell.update(textColor: UIColorManager.TextNorm)
            cell.update(iconColor: self.viewModel.getFolderColor(label: label))
        } else {
            cell.update(textColor: UIColorManager.TextDisabled)
            cell.update(iconColor: self.viewModel.getFolderColor(label: label), alpha: 0.4)
        }
        let isParent = label.location.labelID == self.viewModel.parentID
        cell.accessoryType = isParent ? .checkmark: .none
        cell.addSeparator(padding: 0)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard self.viewModel.isAllowToSelect(row: indexPath.row) else {
            return
        }

        let parentID = self.viewModel.parentID
        let row = parentID.isEmpty ? 0: (self.viewModel.labels.getRow(of: parentID) ?? 0) + 1
        let previous = IndexPath(row: row, section: 0)
        let cell = tableView.cellForRow(at: previous)
        cell?.accessoryType = .none

        let newCell = tableView.cellForRow(at: indexPath)
        newCell?.accessoryType = .checkmark
        self.viewModel.selectRow(row: indexPath.row)
    }
}