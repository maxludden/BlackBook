//
//  ContactFormatter.swift
//  BlackBook
//

import Foundation

struct ContactFormatter {

    // MARK: - Public API

    static func normalize(_ contact: ParsedContact) -> ParsedContact {
        ParsedContact(
            givenName: normalizeName(contact.givenName),
            familyName: normalizeName(contact.familyName),

            organization: trimmedNilIfEmpty(contact.organization),
            jobTitle: trimmedNilIfEmpty(contact.jobTitle),

            emails: dedupe(
                contact.emails.map(normalizeEmail),
                by: \.value
            ),

            phoneNumbers: dedupe(
                contact.phoneNumbers.map(normalizePhone),
                by: \.value
            ),

            urls: dedupe(
                contact.urls.map(normalizeURL),
                by: \.value
            ),

            postalAddresses: contact.postalAddresses,
            dates: contact.dates
        )
    }

    // MARK: - Normalization

    nonisolated static func normalizeName(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    nonisolated static func normalizeEmail(_ email: ParsedEmail) -> ParsedEmail {
        ParsedEmail(
            value: email.value
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased(),
            label: email.label
        )
    }

    nonisolated static func normalizePhone(_ phone: ParsedPhone) -> ParsedPhone {
        let normalized = phone.value.filter { $0.isNumber || $0 == "+" }
        return ParsedPhone(value: normalized, label: phone.label)
    }

    nonisolated static func normalizeURL(_ url: ParsedURL) -> ParsedURL {
        let raw = url.value.trimmingCharacters(in: .whitespacesAndNewlines)
        let value =
            raw.hasPrefix("http://") || raw.hasPrefix("https://")
            ? raw
            : "https://" + raw

        return ParsedURL(value: value, label: url.label)
    }

    // MARK: - Deduplication

    nonisolated static func dedupe<T, K: Hashable>(
        _ items: [T],
        by keyPath: KeyPath<T, K>
    ) -> [T] {
        var seen = Set<K>()
        return items.filter { seen.insert($0[keyPath: keyPath]).inserted }
    }

    // MARK: - Utilities

    nonisolated static func trimmedNilIfEmpty(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty
        else { return nil }
        return trimmed
    }
}
