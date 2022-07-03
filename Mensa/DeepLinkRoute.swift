//
//  DeepLinkRoute.swift
//  Mensa
//
//  Created by David Klopp on 02.07.22.
//

import Foundation
import SwiftUI

enum DeepLinkRoute {
    case location(Location)

    init?(url: URL) {
        let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true)
        guard let host = components?.host, let path = components?.path else {
            return nil
        }

        let rawValueString = path.starts(with: "/") ? String(path.dropFirst()) : path
        guard let rawValue = Int(rawValueString) else {
            return nil
        }

        switch host {
        case "location":    self = .location(Location(rawValue: rawValue))
        default:                return nil
        }
    }
}
