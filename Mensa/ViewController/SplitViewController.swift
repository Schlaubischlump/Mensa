//
//  ViewController.swift
//  Mensa
//
//  Created by David Klopp on 28.06.22.
//

import UIKit

class SplitViewController: UISplitViewController {

    var primaryViewController: UIViewController {
        return self.viewControllers[0]
    }

    var detailViewController: UIViewController? {
        get { return self.viewControllers.count > 1 ? self.viewControllers[1] : nil }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        self.maximumPrimaryColumnWidth = 250
        self.preferredDisplayMode = .oneBesideSecondary
        self.preferredSplitBehavior = .tile

        let sidebarViewController = SidebarViewController()
        let navigationController = UINavigationController(rootViewController: sidebarViewController)
        navigationController.navigationBar.prefersLargeTitles = true

        #if targetEnvironment(macCatalyst)
        navigationController.isNavigationBarHidden = true
        self.primaryBackgroundStyle = .sidebar
        #else
        navigationController.isNavigationBarHidden = false
        self.primaryBackgroundStyle = .none
        #endif

        self.viewControllers = [navigationController]
    }
}

extension SplitViewController: UISplitViewControllerDelegate {
    func splitViewController(_ svc: UISplitViewController,
                             topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column)
    -> UISplitViewController.Column {
        // Prevent the iPhone from pushing a dummy detail view controller on the fisrt appearance
        if let navController = self.detailViewController as? UINavigationController,
            let _ = navController.topViewController as? DetailViewController {
            return .secondary
        }
        return .primary
    }
}

