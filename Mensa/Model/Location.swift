//
//  Location.swift
//  Mensa
//
//  Created by David Klopp on 28.06.22.
//

import Foundation
import UIKit

enum Location: RawRepresentable, Hashable {
    case canteen
    case mensaria
    case holzstrasse
    case cafeK3
    case canteenBingen
    case georgForster
    case foodTruck
    case miniCanteenArt
    case miniCanteenCampusGarden
    case miniCanteenSport
    case cafeBingen
    case unknown(Int)

    static var allCases: [Location] = [310, 312, 330, 340, 360, 370, 431, 446, 447, 448, 449].map {
            Location(rawValue: $0)
    }.sorted { $0.rawValue < $1.rawValue }

    init(rawValue: Int) {
        switch rawValue {
        case 310:   self = .canteen
        case 312:   self = .mensaria
        case 330:   self = .holzstrasse
        case 340:   self = .cafeK3
        case 360:   self = .canteenBingen
        case 370:   self = .georgForster
        case 431:   self = .cafeBingen
        case 446:   self = .foodTruck
        case 447:   self = .miniCanteenArt
        case 448:   self = .miniCanteenCampusGarden
        case 449:   self = .miniCanteenSport
        default:    self = .unknown(rawValue)
        }
    }

    var rawValue: Int {
        switch self {
        case .canteen:                      return 310
        case .mensaria:                     return 312
        case .holzstrasse:                  return 330
        case .cafeK3:                       return 340
        case .canteenBingen:                return 360
        case .georgForster:                 return 370
        case .cafeBingen:                   return 431
        case .foodTruck:                    return 446
        case .miniCanteenArt:               return 447
        case .miniCanteenSport:             return 448
        case .miniCanteenCampusGarden:      return 449
        case .unknown(let rawValue):  return rawValue
        }
    }

    var name: String {
        switch self {
        case .canteen:                  return "Zentralmensa"
        case .mensaria:                 return "Mensaria"
        case .holzstrasse:              return "Mensa Holzstraße"
        case .cafeK3:                   return "Café K3"
        case .canteenBingen:            return "Mensa Bingen"
        case .georgForster:             return "Mensa Georg Forster"
        case .cafeBingen:               return "Cafe Bingen Rochusberg"
        case .foodTruck:                return "Foodtruck"
        case .miniCanteenArt:           return "Mini Mensa Kunst"
        case .miniCanteenCampusGarden:  return "Mini Mensa Campusgarten"
        case .miniCanteenSport:         return "Mini Mensa Sport"
        case .unknown(let rawValue):    return "Unknown \(rawValue)"
        }
    }

    var numberOfCounters: Int {
        switch self {
        case .cafeBingen:
            return 1
        case .miniCanteenArt, .miniCanteenCampusGarden, .miniCanteenSport, .georgForster, .holzstrasse, .mensaria:
            return 2
        case .canteenBingen, .foodTruck:
            return 3
        default:
            return 4
        }
    }

    var icon: UIImage? {
        var imageName: String?
        switch self {
        case .canteen:                  imageName = "circle.circle"
        case .mensaria:                 imageName = "mensaria"
        case .holzstrasse:              imageName = "leaf.fill"
        case .cafeK3:                   imageName = "curlybraces"
        case .canteenBingen:            imageName = "grid"
        case .georgForster:             imageName = "person.fill"
        case .cafeBingen:               imageName = "ellipsis.curlybraces"
        case .foodTruck:                imageName = "train.side.rear.car"
        case .miniCanteenArt:           imageName = "paintpalette.fill"
        case .miniCanteenCampusGarden:  imageName = "ladybug.fill"
        case .miniCanteenSport:         imageName = "sportscourt.fill"
        case .unknown:                  imageName = "questionmark.circle"
        }

        if let imageName = imageName {
            return UIImage(systemName: imageName) ?? UIImage(named: imageName)
        }
        return nil
    }
}
