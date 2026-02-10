//
//  ParsedContact.swift
//  BlackBook
//
//  Created by Maxwell Ludden on 2/10/26.
//


import Foundation

struct ParsedContact {
    var givenName: String
    var familyName: String

    var organization: String?
    var jobTitle: String?

    var emails: [ParsedEmail]
    var phoneNumbers: [ParsedPhone]
    var urls: [ParsedURL]
    var postalAddresses: [ParsedPostalAddress]
    var dates: [ParsedDate]
    
    var identityKey: String {
        "\(givenName.lowercased())|\(familyName.lowercased())"
    }
}

struct ParsedEmail {
    var value: String
    var label: String?
}

struct ParsedPhone {
    var value: String
    var label: String?
}

struct ParsedURL {
    var value: String
    var label: String?
}

struct ParsedPostalAddress {
    var street: String?
    var city: String?
    var state: String?
    var postalCode: String?
    var country: String?
    var label: String?
}

struct ParsedDate {
    var date: Date
    var label: String?
}
