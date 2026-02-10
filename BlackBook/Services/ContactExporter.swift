//
//  ContactExporter.swift
//  BlackBook
//

import Foundation

struct ContactExporter {

    static func parsed(from contact: Contact) -> ParsedContact {

        let parsedEmails: [ParsedEmail] = contact.emails.compactMap { email in
            guard !email.address.isEmpty else { return nil }
            return ParsedEmail(
                value: email.address,
                label: email.type.rawValue
            )
        }

        let parsedPhones: [ParsedPhone] = contact.phoneNumbers.compactMap { phone in
            guard !phone.number.isEmpty else { return nil }
            return ParsedPhone(
                value: phone.number,
                label: phone.type.rawValue
            )
        }

        let parsedURLs: [ParsedURL] = contact.urls.compactMap { item in
            let value = item.url.absoluteString
            guard !value.isEmpty else { return nil }
            return ParsedURL(
                value: value,
                label: item.label
            )
        }

        let parsedAddresses: [ParsedPostalAddress] = contact.addresses.map { address in
            ParsedPostalAddress(
                street: address.street,
                city: address.city,
                state: address.state,
                postalCode: address.postalCode,
                country: address.country,
                label: address.label
            )
        }

        let parsedDates: [ParsedDate] = contact.dates.map { d in
            ParsedDate(
                date: d.date,
                label: d.label
            )
        }

        return ParsedContact(
            givenName: contact.givenName,
            familyName: contact.familyName,
            organization: contact.organization,
            jobTitle: contact.jobTitle,
            emails: parsedEmails,
            phoneNumbers: parsedPhones,
            urls: parsedURLs,
            postalAddresses: parsedAddresses,
            dates: parsedDates
        )
    }
}
