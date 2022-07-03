//
//  MensaAPI.swift
//  Mensa
//
//  Created by David Klopp on 28.06.22.
//

import Foundation
import SWXMLHash

enum APIError: Error {
    case errorFetchingRows
}

class API {
    public static let primaryURL = URL(string: "https://www.studierendenwerk-mainz.de/speiseplan/Speiseplan.xml")!

    public static func fetchFields() async throws -> [Field] {
        let (data, response) = try await URLSession.shared.data(from: API.primaryURL)

        guard (response as? HTTPURLResponse)?.statusCode == 200  else {
            throw APIError.errorFetchingRows
        }

        let xml = XMLHash.parse(data)
        let datapacket = xml["DATAPACKET"]
        let metadata = datapacket["METADATA"]

        return metadata["FIELDS"]["FIELD"].all.compactMap { fieldIndexer in
            if let fieldElement = fieldIndexer.element {
                return try? Field(xmlElement: fieldElement)
            }
            return nil
        }
    }

    public static func fetchRows() async throws -> [Row] {
        let (data, response) = try await URLSession.shared.data(from: API.primaryURL)

        guard (response as? HTTPURLResponse)?.statusCode == 200  else {
            throw APIError.errorFetchingRows
        }

        let xml = XMLHash.parse(data)
        let datapacket = xml["DATAPACKET"]

        return datapacket["ROWDATA"]["ROW"].all.compactMap { rowIndexer in
            if let rowElement = rowIndexer.element {
                return try? Row(xmlElement: rowElement)
            }
            return nil
        }
    }
}


