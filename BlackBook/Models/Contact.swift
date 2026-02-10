

//
//  Contact.swift
//  BlackBook
//
//  Created by Maxwell Ludden on 2/10/26

import Foundation
import SwiftData

@Model
final class Contact {
    @Attribute(.unique) var uid: UUID
    var createdAt: Date
    var updatedAt: Date

    // Identity
    var givenName: String
    var familyName: String
    var middleName: String?
    var prefix: String?
    var suffix: String?
    var nickname: String?

    // Org
    var organization: String?
    var department: String?
    var jobTitle: String?

    // Notes
    var notes: String?

    // Relationships
    @Relationship(deleteRule: .cascade)
    var phoneNumbers: [PhoneNumber]

    @Relationship(deleteRule: .cascade)
    var emails: [EmailAddress]

    @Relationship(deleteRule: .cascade)
    var addresses: [PostalAddress]

    @Relationship(deleteRule: .cascade)
    var urls: [ContactURL]

    @Relationship(deleteRule: .cascade)
    var dates: [ContactDate]

    @Relationship(deleteRule: .cascade)
    var mediaItems: [ContactMedia]

    init(givenName: String, familyName: String) {
        self.uid = UUID()
        self.createdAt = .now
        self.updatedAt = .now
        self.givenName = givenName
        self.familyName = familyName
        self.phoneNumbers = []
        self.emails = []
        self.addresses = []
        self.urls = []
        self.dates = []
        self.mediaItems = []
    }

    var displayName: String {
        let parts = [givenName, familyName]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return parts.isEmpty ? "Unnamed Contact" : parts.joined(separator: " ")
    }
}
