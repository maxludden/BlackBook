//
//  ContactDetailView.swift
//  BlackBook
//
//  Created by Maxwell Ludden on 2/10/26.
//

import SwiftUI
import SwiftData

struct ContactDetailView: View {
    @Bindable var contact: Contact

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                identitySection
                communicationSection
                addressSection
                notesSection
            }
            .padding()
        }
        .navigationTitle(contactDisplayName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Sections

private extension ContactDetailView {

    var headerSection: some View {
        VStack(spacing: 12) {
            // Placeholder avatar (replace with primary photo later)
            Circle()
                .fill(.gray.opacity(0.3))
                .frame(width: 96, height: 96)

            Text(contactDisplayName)
                .font(.title2)
                .fontWeight(.semibold)

            if let organization = contact.organization, !organization.isEmpty {
                Text(organization)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let jobTitle = contact.jobTitle, !jobTitle.isEmpty {
                Text(jobTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    var identitySection: some View {
        DetailSection(title: "Identity") {
            DetailRow(label: "Given Name", value: contact.givenName)
            DetailRow(label: "Family Name", value: contact.familyName)

            if let nickname = contact.nickname {
                DetailRow(label: "Nickname", value: nickname)
            }

            if let prefix = contact.prefix {
                DetailRow(label: "Prefix", value: prefix)
            }

            if let suffix = contact.suffix {
                DetailRow(label: "Suffix", value: suffix)
            }
        }
    }

    var communicationSection: some View {
        DetailSection(title: "Communication") {
            if contact.phoneNumbers.isEmpty &&
                contact.emails.isEmpty &&
                contact.urls.isEmpty {
                emptyRow("No contact methods")
            }

            ForEach(contact.phoneNumbers, id: \.self) { phone in
                DetailRow(
                    label: phone.type.rawValue.capitalized,
                    value: phone.number
                )
            }

            ForEach(contact.emails, id: \.self) { email in
                DetailRow(
                    label: email.type.rawValue.capitalized,
                    value: email.address
                )
            }

            ForEach(contact.urls, id: \.self) { url in
                if let actualURL = url.url {
                    let labelText = (url.label?.isEmpty == false) ? (url.label ?? "Website") : "Website"
                    DetailRow(
                        label: labelText,
                        value: actualURL.absoluteString
                    )
                }
            }
        }
    }

    var addressSection: some View {
        DetailSection(title: "Addresses") {
            if contact.addresses.isEmpty {
                emptyRow("No addresses")
            } else {
                ForEach(Array(contact.addresses.enumerated()), id: \.offset) { _, address in
                    VStack(alignment: .leading, spacing: 4) {
                        Text((address.label?.isEmpty == false) ? (address.label ?? "Address") : "Address")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(formattedAddress(address))
                            .font(.body)
                    }
                }
            }
        }
    }

    var notesSection: some View {
        Group {
            if let notes = contact.notes, !notes.isEmpty {
                DetailSection(title: "Notes") {
                    Text(notes)
                        .font(.body)
                }
            }
        }
    }
}

// MARK: - Helpers

private extension ContactDetailView {

    var contactDisplayName: String {
        "\(contact.givenName) \(contact.familyName)"
    }

    func emptyRow(_ text: String) -> some View {
        Text(text)
            .font(.body)
            .foregroundStyle(.secondary)
    }

    func formattedAddress(_ address: PostalAddress) -> String {
        let parts: [String] = [
            address.street,
            address.city,
            address.state,
            address.postalCode,
            address.country
        ]
        .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }

        return parts.joined(separator: ", ")
    }
}

// MARK: - Reusable Components

private struct DetailSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                content
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

private struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
    }
}

