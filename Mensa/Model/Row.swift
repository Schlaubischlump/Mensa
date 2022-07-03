//
//  Row.swift
//  Mensa
//
//  Created by David Klopp on 28.06.22.
//

import SWXMLHash
import Foundation

private let kMenuIndicatorsMap = [
    "Veggi" : "🍂",
    "Vegan" : "🍃"
]

private let kMeatAdditivesMap = [
    "S": "🐷",
    "G": "🐔",
    "R": "🐮"
]

private let kAdditivesMap = kMeatAdditivesMap.merging([
    "La": "🥛",
    "Gl": "🌾",
]) { (current, _) in current }


enum RowError: Error {
    case missingLocation
    case missingConsumeLocation
    case missingCounter
    case missingDescription
    case missingDate
}

struct Row: Hashable {
    let location: Location
    let consumeLocation: Location
    let counter: Counter
    let date: Date
    let studentPrice: Float?

    let description: String
    let descriptionEn: String?

    let canteen: String?
    let menuIndicators: [String]
    let additives: [String]
    let food: String?

    let soldOut: String?

    /*
    ARTNR="600.157"
    GEBNR="94.619"
    BEDIENSTETE="   1.82"
    REZHINWEISE=""
     */

    public init(xmlElement element: SWXMLHash.XMLElement) throws {
        guard let locationString = element.attribute(by: "ORT")?.text,
                let location = Int(locationString) else {
            throw RowError.missingLocation
        }

        guard let consumeLocationString = element.attribute(by: "VERBRAUCHSORT")?.text,
                let consumeLocation = Int(consumeLocationString) else {
            throw RowError.missingConsumeLocation
        }

        guard let counterString = element.attribute(by: "TYP")?.text, let counter = Int(counterString) else {
            throw RowError.missingCounter
        }

        guard let description = element.attribute(by: "AUSGABETEXT")?.text else {
            throw RowError.missingDescription
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        guard let dateString = element.attribute(by: "DATUM")?.text,
                let date = dateFormatter.date(from: dateString) else {
            throw RowError.missingDate
        }

        self.location = Location(rawValue: location)
        self.consumeLocation = Location(rawValue: consumeLocation)
        self.counter = Counter(rawValue: counter)
        self.date = date
        self.description = description
        self.descriptionEn = element.attribute(by: "AUSGABETEXTENGL")?.text
        self.canteen = element.attribute(by: "MENSA")?.text
        self.menuIndicators = (element.attribute(by: "MENUEKENNZTEXT")?.text.components(separatedBy: ",") ?? []).map {
            $0.trimmingCharacters(in: .whitespaces)
        }
        self.additives = (element.attribute(by: "ZSNUMMERN")?.text.components(separatedBy: ",") ?? []).map {
            $0.trimmingCharacters(in: .whitespaces)
        }
        self.soldOut = element.attribute(by: "AUSVERKAUFT")?.text
        self.food = element.attribute(by: "SPEISE")?.text

        if let priceString = element.attribute(by: "STUDIERENDE")?.text.trimmingCharacters(in: .whitespaces),
           let price = Float(priceString) {
            self.studentPrice = price
        } else {
            self.studentPrice = nil
        }
    }

    internal init(location: Location, consumeLocation: Location, counter: Counter, date: Date, description: String,
                  studentPrice: Float? = nil, additives: [String] = [], menuIndicators: [String] = []) {
        self.location = location
        self.consumeLocation = consumeLocation
        self.counter = counter
        self.date = date
        self.description = description
        self.menuIndicators = menuIndicators
        self.additives = additives
        self.studentPrice = studentPrice
        self.food = nil
        self.soldOut = nil
        self.descriptionEn = nil
        self.canteen = nil
    }

    public func getPriceString() -> String? {
        guard let price = self.studentPrice else {
            return nil
        }
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "de-DE")
        formatter.numberStyle = .currency
        let studiPrice = formatter.string(from: price as NSNumber) ?? ""
        let fullPrice = formatter.string(from: round(price * 1.655 * 100) / 100 as NSNumber) ?? ""
        return "\(studiPrice) / \(fullPrice)"
    }

    public func getAdditivesText(short: Bool = false) -> String {
        var text = ""
        if self.menuIndicators.contains("Vegan") {
            text += kMenuIndicatorsMap["Vegan"] ?? ""
        } else if menuIndicators.contains("Veggi") {
            text += kMenuIndicatorsMap["Veggi"] ?? ""
        }

        (short ? kMeatAdditivesMap : kAdditivesMap).forEach { key, value in
            text += additives.contains(key) ? value : ""
        }
        return text
    }
}
