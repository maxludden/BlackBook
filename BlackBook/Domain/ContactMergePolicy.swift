//
//  ContactMergePolicy.swift
//  BlackBook
//
//  Created by Maxwell Ludden on 2/10/26.
//


import Foundation

enum ContactMergePolicy {

    static func merge(
        incoming: ParsedContact,
        existing: ParsedContact
    ) -> ParsedContact {

        ParsedContact(
            givenName: existing.givenName,
            familyName: existing.familyName,

            organization: existing.organization ?? incoming.organization,
            jobTitle: existing.jobTitle ?? incoming.jobTitle,

            emails: merge(
                existing.emails,
                incoming.emails,
                by: \.value
            ),

            phoneNumbers: merge(
                existing.phoneNumbers,
                incoming.phoneNumbers,
                by: \.value
            ),

            urls: merge(
                existing.urls,
                incoming.urls,
                by: \.value
            ),

            postalAddresses: merge(
                existing.postalAddresses,
                incoming.postalAddresses,
                by: \.street
            ),

            dates: merge(
                existing.dates,
                incoming.dates,
                by: \.date
            )
        )
    }

    private static func merge<T, K: Hashable>(
        _ existing: [T],
        _ incoming: [T],
        by keyPath: KeyPath<T, K?>
    ) -> [T] {

        var seen = Set<K>()
        let combined = existing + incoming

        return combined.filter {
            guard let key = $0[keyPath: keyPath] else { return true }
            return seen.insert(key).inserted
        }
    }

    private static func merge<T, K: Hashable>(
        _ existing: [T],
        _ incoming: [T],
        by keyPath: KeyPath<T, K>
    ) -> [T] {

        var seen = Set<K>()
        let combined = existing + incoming

        return combined.filter {
            let key = $0[keyPath: keyPath]
            return seen.insert(key).inserted
        }
    }
}
