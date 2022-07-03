//
//  Field.swift
//  Mensa
//
//  Created by David Klopp on 28.06.22.
//

import SWXMLHash

enum FieldError: Error {
    case missingFieldType
    case missingFieldName
    case missingDisplayLabel
    case missingFieldClass
}

struct Field {
    var fieldType: String
    var fieldName: String
    var displayLabel: String
    var fieldClass: String

    public init(xmlElement element: XMLElement) throws {
        guard let fieldType = element.attribute(by: "FieldType")?.text else {
            throw FieldError.missingFieldType
        }

        guard let fieldName = element.attribute(by: "FieldName")?.text else {
            throw FieldError.missingFieldName
        }

        guard let displayLabel = element.attribute(by: "DisplayLabel")?.text else {
            throw FieldError.missingDisplayLabel
        }

        guard let fieldClass = element.attribute(by: "FieldClass")?.text else {
            throw FieldError.missingFieldClass
        }

        self.fieldType = fieldType
        self.fieldName = fieldName
        self.displayLabel = displayLabel
        self.fieldClass = fieldClass
    }

    public init(fieldType: String, fieldName: String, displayLabel: String, fieldClass: String) {
        self.fieldType = fieldType
        self.fieldName = fieldName
        self.displayLabel = displayLabel
        self.fieldClass = fieldClass
    }
}
