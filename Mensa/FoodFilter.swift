//
//  UserDefaults+Extension.swift
//  Mensa
//
//  Created by David Klopp on 03.07.22.
//

import Foundation

let kFilterKey = "filter"

@objc enum FoodFilter: Int {
    case all = 0
    case veggi = 1
    case vegan = 2

    private var menuIndicatorString: String? {
        switch self {
        case .all: return nil
        case .veggi: return "veggi"
        case .vegan: return "vegan"
        }
    }

    public func check(menuIndicators: [String]) -> Bool {
        if let indicator = self.menuIndicatorString {
            return menuIndicators.contains { $0.lowercased() == indicator.lowercased() }
        }
        return true
    }
}

// IMPORTANT: The variable name MUST always match the key !!!! Otherwise kvo will not work.
extension UserDefaults {
    @objc dynamic var filter: FoodFilter {
        get { return FoodFilter(rawValue: self.integer(forKey: kFilterKey)) ?? .all }
        set { self.setValue(newValue.rawValue, forKey: kFilterKey) }
    }
}
