//
//  SnapshotData.swift
//  Mensa
//
//  Created by David Klopp on 01.07.22.
//

import Foundation

// MARK: Snapshot data

let kSnapshotLocation: Location = .mensaria

let kSnapshotData: [Row] = [
    Row(location: kSnapshotLocation,
        consumeLocation: kSnapshotLocation,
        counter: .one(1),
        date: .now,
        description: "Putengeschnetzeltes \"Züricher Art\" (5,Gl,La,Sl,Sw,G,Ge)",
        studentPrice: 3.50,
        additives: ["G"],
        menuIndicators: ["Veggi", "Vegan"]
    ),
    Row(location: kSnapshotLocation,
        consumeLocation: kSnapshotLocation,
        counter: .one(1),
        date: .now,
        description: "Currywurst vom Schwein (3,S) oder Rindscurrywurst (2,3,8,La,Sl,Sf,R) oder Vegane Currywurst (So,Sl) mit Currysauce (1,2,9) und Pommes frites",
        studentPrice: 3.10,
        additives: ["S", "R"],
        menuIndicators: []
    ),
    Row(location: kSnapshotLocation,
        consumeLocation: kSnapshotLocation,
        counter: .one(1),
        date: .now,
        description: "Mainzer Bratwurst im Brötchen, auch in vegan erhältlich (2,3,8,Gl,So,La,Sl,Sf,S,R,We)",
        studentPrice: 1.80,
        additives: ["G"],
        menuIndicators: []
    ),
    Row(location: kSnapshotLocation,
        consumeLocation: kSnapshotLocation,
        counter: .dishOfTheDay(0),
        date: .now,
        description: "3 Karotten-Kürbis Rösti (Gl,Ei,Sl,We) getoppt mit Schnittlauchsauce (La) dazu Reis",
        studentPrice: 3.52,
        additives: ["La"],
        menuIndicators: ["Veggi"]
    ),
]


// MARK: - Enum extensions

extension WidgetParameterCounter {
    var orderIndex: OrderIndex {
        switch self {
        case .one:      return .one
        case .two:      return .two
        case .three:    return .three
        case .four:     return .four
        case .side:     return .side
        case .unknown:  return .ignore
        }
    }
}

extension WidgetParameterMensa {
    var location: Location {
        switch self {
        case .canteen:                  return .canteen
        case .mensaria:                 return .mensaria
        case .holzstrasse:              return .holzstrasse
        case .cafeK3:                   return .cafeK3
        case .canteenBingen:            return .canteenBingen
        case .georgForster:             return .georgForster
        case .cafeBingen:               return .cafeBingen
        case .foodTruck:                return .foodTruck
        case .miniCanteenArt:           return .miniCanteenArt
        case .miniCanteenCampusGarden:  return .miniCanteenCampusGarden
        case .miniCanteenSport:         return .miniCanteenSport
        case .unknown:                  return .unknown(0)
        }
    }
}
