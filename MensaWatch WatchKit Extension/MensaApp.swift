//
//  MensaApp.swift
//  MensaWatch WatchKit Extension
//
//  Created by David Klopp on 03.07.22.
//

import SwiftUI

@main
struct MensaApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                LocationsListView()
            }
        }
    }
}
