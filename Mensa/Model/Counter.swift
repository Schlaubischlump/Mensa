//
//  Counter.swift
//  Mensa
//
//  Created by David Klopp on 28.06.22.
//

import Foundation

enum OrderIndex: Int {
    case ignore = -1
    case one = 0
    case two = 1
    case three = 2
    case four = 3
    case side = 4

    public var defaultCounter: Counter {
        switch self {
        case .one:      return .one(1)
        case .two:      return .two(2)
        case .three:    return .three(3)
        case .four:     return .four(4)
        default:        return .sideDishes(0)
        }
    }
}

enum Counter: RawRepresentable, Hashable {
    case soupOfTheDay(Int)
    case stew(Int)
    case sideDishes(Int)
    case topping(Int)
    case one(Int)
    case two(Int)
    case three(Int)
    case four(Int)
    case wok(Int)
    case dishOfTheDay(Int)
    case snack(Int)
    case ignore(Int)
    case unknown(Int)
    case special(Int)

    init(rawValue: Int) {
        switch rawValue {
        case 100:
            self = .soupOfTheDay(rawValue)
        case 102, 501:
            self = .stew(rawValue)
        case 104:
            self = .snack(rawValue)
        case 821, 822, 823, 824, 842, 843, 844:
            self = .topping(rawValue)
        case 110, 112, 113, 150, 158, 160, 170, 190, 203, 304, 401, 800, 802, 830, 832, 820, 840, 841:
            self = .one(rawValue)
        case 120, 151, 161, 192, 300, 807, 831, 833:
            self = .two(rawValue)
        case 130, 803:
            self = .three(rawValue)
        case 140, 142:
            self = .four(rawValue)
        case 200, 201, 202:
            self = .sideDishes(rawValue)
        case 302:
            self = .dishOfTheDay(rawValue)
        case 303:
            self = .wok(rawValue)
        case 114:
            self = .special(rawValue)
        // No idea what this is, but it is not displayed... Maybe some old data
        case 18, 125, 700: self = .ignore(rawValue)
        default: self = .unknown(rawValue)
        }
    }

    var rawValue: Int {
        switch self {
        case .soupOfTheDay(let rawValue):         fallthrough
        case .stew(let rawValue):                 fallthrough
        case .topping(let rawValue):              fallthrough
        case .one(let rawValue):                  fallthrough
        case .two(let rawValue):                  fallthrough
        case .three(let rawValue):                fallthrough
        case .four(let rawValue):                 fallthrough
        case .dishOfTheDay(let rawValue):         fallthrough
        case .wok(let rawValue):                  fallthrough
        case .snack(let rawValue):                fallthrough
        case .sideDishes(let rawValue):           fallthrough
        case .ignore(let rawValue):               fallthrough
        case .special(let rawValue):             fallthrough
        case .unknown(let rawValue):              return rawValue
        }
    }

    var name: String {
        switch self {
        case .soupOfTheDay:         return "Tagessuppe"
        case .sideDishes:           return "Beilagen"
        case .stew:                 return "Eintopf"
        case .topping:              return "Topping"
        case .one:                  return "Ausgabe 1"
        case .two:                  return "Ausgabe 2"
        case .three:                return "Ausgabe 3"
        case .four:                 return "Ausgabe 4"
        case .dishOfTheDay:         return "Tagesessen"
        case .wok:                  return "Wok"
        case .snack:                return "Snacken"
        case .special:              return "Spezial-Aktion"
        case .ignore:               return "Ignore \(rawValue)"
        case .unknown(let rawValue): return "Unknown \(rawValue)"
        }
    }

    var orderIndex: OrderIndex {
        switch self {
        case .soupOfTheDay:         return .side
        case .sideDishes:           return .side
        case .stew:                 return .side
        case .topping:              return .two
        case .one:                  return .one
        case .two:                  return .two
        case .three:                return .three
        case .four:                 return .four
        case .dishOfTheDay:         return .two
        case .wok:                  return .one
        case .snack:                return .side
        case .special:             return .one
        case .unknown:              return .ignore
        case .ignore:               return .ignore
        }
    }
}
