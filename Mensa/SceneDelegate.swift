//
//  SceneDelegate.swift
//  Mensa
//
//  Created by David Klopp on 28.06.22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = scene as? UIWindowScene else {
            fatalError("Expected scene of type UIWindowScene but got an unexpected type")
        }

        self.window = UIWindow(windowScene: windowScene)

        if let window = self.window {
            window.rootViewController = SplitViewController(style: .doubleColumn)

            #if targetEnvironment(macCatalyst)

            let toolbar = NSToolbar(identifier: NSToolbar.Identifier("MensaSceneDelegate.Toolbar"))
            //toolbar.delegate = self
            toolbar.displayMode = .iconOnly
            toolbar.allowsUserCustomization = false
            toolbar.delegate = self

            windowScene.titlebar?.toolbar = toolbar
            windowScene.titlebar?.toolbarStyle = .unified

            #endif

            window.makeKeyAndVisible()
        }

        self.handleURLContext(openURLContexts: connectionOptions.urlContexts.first)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        self.handleURLContext(openURLContexts: URLContexts.first)
    }

    private func handleURLContext(openURLContexts urlContext: UIOpenURLContext?) {
        guard let url = urlContext?.url else {
            return
        }

        // Resolve the URL
        guard let route = DeepLinkRoute(url: url) else {
            return
        }

        switch route {
        case .location(let location):
            let splitViewController = self.window?.rootViewController as? SplitViewController
            let sidebarNav = splitViewController?.viewControllers[safe: 0] as? UINavigationController
            // Pop back to the sidebar view controller. This is important on iPhone / compact layout.
            sidebarNav?.popToRootViewController(animated: false)
            if case .unknown = location {
                // Unknown location... Nothing to do. Just stay at the sidebar view.
            } else {
                let topbarController = sidebarNav?.topViewController as? SidebarViewController
                topbarController?.select(location: location)
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

#if targetEnvironment(macCatalyst)
extension SceneDelegate: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.toggleSidebar]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.toggleSidebar]
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        return NSToolbarItem(itemIdentifier: itemIdentifier)
    }
}
#endif
