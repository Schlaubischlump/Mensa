//
//  SidebarViewController.swift
//  Mensa
//
//  Created by David Klopp on 28.06.22.
//

import UIKit

#if targetEnvironment(macCatalyst)
let kUseHeader = true
#else
import InAppSettingsKit
let kUseHeader = false
#endif


enum SidebarSection: Int {
    case mensa
}

enum SidebarItem: Hashable {
    case header
    case row(Location)

    static var allCases: [SidebarItem] {
        if kUseHeader {
            return [.header] + Location.allCases.map { .row($0) }
        }
        return Location.allCases.map { .row($0) }
    }

    var title: String {
        switch self {
        case .header:               return "Mensa"
        case .row(let location):    return location.name
        }
    }

    var icon: UIImage? {
        switch self {
        case .header:               return nil
        case .row(let location):    return location.icon
        }
    }
}

class SidebarViewController: UIViewController {

    private var dataSource: UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>?

    override func loadView() {
        let layout = UICollectionViewCompositionalLayout() {
            (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in

            // If we present this viewController without a detailed controller, we slightly change the design
            let isCollapsed = self.splitViewController?.isCollapsed ?? false

            var configuration = UICollectionLayoutListConfiguration(appearance: isCollapsed ? .sidebarPlain : .sidebar)
            configuration.showsSeparators = isCollapsed ? true : false
            configuration.headerMode = kUseHeader ? .firstItemInSection : .none
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            return section
        }

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        self.view = collectionView

        collectionView.delegate = self

        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> {
            cell, _, item in

            let isCollapsed = self.splitViewController?.isCollapsed ?? false

            let imageSize = CGSize(width: UIFloat(20), height: UIFloat(20))
            var contentConfiguration = UIListContentConfiguration.sidebarCell()
            contentConfiguration.text = item.title
            contentConfiguration.image = item.icon
            contentConfiguration.imageProperties.maximumSize = imageSize
            contentConfiguration.imageProperties.reservedLayoutSize = imageSize
            cell.contentConfiguration = contentConfiguration

            if isCollapsed {
                cell.accessories = [.disclosureIndicator()]
            }
        }

        let headerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> {
            (cell, indexPath, item) in

            var contentConfiguration = UIListContentConfiguration.sidebarHeader()
            contentConfiguration.text = item.title
            contentConfiguration.textProperties.font = .preferredFont(forTextStyle: .subheadline)
            contentConfiguration.textProperties.color = .secondaryLabel
            cell.contentConfiguration = contentConfiguration
        }

        self.dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) {
            collectionView, indexPath, item -> UICollectionViewCell? in
            switch item {
            case .header:
                return collectionView.dequeueConfiguredReusableCell(using: headerRegistration, for: indexPath, item: item)
            default:
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            }
        }

        // Apply the initial snapshot
        var categorySnapshot = NSDiffableDataSourceSnapshot<SidebarSection, SidebarItem>()
        categorySnapshot.appendSections([.mensa])
        categorySnapshot.appendItems(SidebarItem.allCases, toSection: .mensa)
        self.dataSource?.apply(categorySnapshot, animatingDifferences: false)

        self.title = SidebarItem.header.title

        #if !targetEnvironment(macCatalyst)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"),
                                                                 style: .plain, target: self,
                                                                 action: #selector(self.showSettings(sender:)))
        #endif
    }

    #if !targetEnvironment(macCatalyst)
    @objc private func showSettings(sender: Any) {
        let appSettingsViewController = IASKAppSettingsViewController()
        appSettingsViewController.showDoneButton = true
        appSettingsViewController.delegate = self
        let navController = UINavigationController(rootViewController: appSettingsViewController)
        self.present(navController, animated: true)
    }
    #endif

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let collectionView = self.view as? UICollectionView else {
            return
        }

        if let indexPaths = collectionView.indexPathsForSelectedItems, indexPaths.count > 0 {
            // Deselect all sidebar items on a compact layout
            if self.splitViewController?.viewControllers.count == 1 {
                indexPaths.forEach {
                    collectionView.deselectItem(at: $0, animated: false)
                }
            }
        } else if !(self.splitViewController?.isCollapsed ?? true) {
            // Select the first item if no item is selected
            self.select(row: 0)
        }
    }

    @discardableResult
    public func select(location: Location) -> Bool {
        guard let locationIndexToSelect = Location.allCases.firstIndex(of: location) else {
            return false
        }
        return self.select(row: locationIndexToSelect)
    }

    @discardableResult
    public func select(row: Int) -> Bool {
        guard let collectionView = self.view as? UICollectionView else {
            return false
        }
        let indexPath = IndexPath(item: kUseHeader ? row + 1 : row, section: 0)
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
        self.collectionView(collectionView, didSelectItemAt: indexPath)
        return true
    }
}
    // MARK: - UICollectionViewDelegate
extension SidebarViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row - (indexPath.section + (kUseHeader ? 1 : 0))

        guard index >= 0 else {
            return
        }

        let location = Location.allCases[index]
        let detailViewController = DetailViewController(location: location)
        // We don't want the splitview to push all our views on a navigation stack. Therefore encapsulate the view
        // in a navigation controller.
        let navController = UINavigationController(rootViewController: detailViewController)
        self.splitViewController?.showDetailViewController(navController, sender: self)

        // Update the window title
        UIApplication.shared.connectedScenes.forEach {
            $0.title = location.name
        }
    }
}

#if !targetEnvironment(macCatalyst)
extension SidebarViewController: IASKSettingsDelegate {
    func settingsViewControllerDidEnd(_ settingsViewController: IASKAppSettingsViewController) {
        self.dismiss(animated: true)
    }
}
#endif
