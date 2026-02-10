//
//  ContactBuilder.swift
//  BlackBook
//
//  Created by Maxwell Ludden on 2/10/26.
//


import SwiftData
import Foundation

struct ContactBuilder {

    static func insert(
        _ parsed: ParsedContact,
        into context: ModelContext
    ) -> Contact {

        let contact = Contact(
            givenName: parsed.givenName,
            familyName: parsed.familyName
        )

        contact.organization = parsed.organization
        contact.jobTitle = parsed.jobTitle

        parsed.emails.forEach {
            contact.emails.append(
                EmailAddress($0.value, label: $0.label)
            )
        }

        parsed.phoneNumbers.forEach {
            contact.phoneNumbers.append(
                PhoneNumber(number: $0.value, type: .mobile, label: $0.label)
            )
        }

        parsed.urls.forEach {
            contact.urls.append(
                ContactURL(urlString: $0.value, label: $0.label)
            )
        }

        parsed.postalAddresses.forEach {
            contact.addresses.append(
                PostalAddress(
                    street: $0.street,
                    city: $0.city,
                    state: $0.state,
                    postalCode: $0.postalCode,
                    country: $0.country,
                    label: $0.label
                )
            )
        }

        parsed.dates.forEach {
            contact.dates.append(
                ContactDate(date: $0.date, label: $0.label)
            )
        }

        context.insert(contact)
        return contact
    }
}

