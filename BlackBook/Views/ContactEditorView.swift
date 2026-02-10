//
//  ContactEditorView.swift
//  BlackBook
//
//  Created by Maxwell Ludden on 2/10/26.
//


import SwiftUI
import SwiftData

struct ContactEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // If nil → creating a new contact
    private let contact: Contact?

    // Editable state
    @State private var givenName: String = ""
    @State private var familyName: String = ""
    @State private var middleName: String = ""
    @State private var prefix: String = ""
    @State private var suffix: String = ""
    @State private var nickname: String = ""

    @State private var organization: String = ""
    @State private var department: String = ""
    @State private var jobTitle: String = ""

    @State private var notes: String = ""

    init(contact: Contact? = nil) {
        self.contact = contact
    }

    var body: some View {
        NavigationStack {
            Form {
                identitySection
                organizationSection
                notesSection
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(trimmedGivenName.isEmpty && trimmedFamilyName.isEmpty)
                }
            }
            .onAppear(perform: loadContact)
        }
    }
}

// MARK: - Sections

private extension ContactEditorView {

    var identitySection: some View {
        Section("Identity") {
            TextField("Given Name", text: $givenName)
            TextField("Family Name", text: $familyName)
            TextField("Middle Name", text: $middleName)
            TextField("Nickname", text: $nickname)
            TextField("Prefix", text: $prefix)
            TextField("Suffix", text: $suffix)
        }
    }

    var organizationSection: some View {
        Section("Organization") {
            TextField("Organization", text: $organization)
            TextField("Department", text: $department)
            TextField("Job Title", text: $jobTitle)
        }
    }

    var notesSection: some View {
        Section("Notes") {
            TextEditor(text: $notes)
                .frame(minHeight: 100)
        }
    }
}

// MARK: - Helpers

private extension ContactEditorView {

    var navigationTitle: String {
        contact == nil ? "New Contact" : "Edit Contact"
    }

    var trimmedGivenName: String {
        givenName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedFamilyName: String {
        familyName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func loadContact() {
        guard let contact else { return }

        givenName = contact.givenName
        familyName = contact.familyName
        middleName = contact.middleName ?? ""
        prefix = contact.prefix ?? ""
        suffix = contact.suffix ?? ""
        nickname = contact.nickname ?? ""

        organization = contact.organization ?? ""
        department = contact.department ?? ""
        jobTitle = contact.jobTitle ?? ""

        notes = contact.notes ?? ""
    }

    func save() {
        if let contact {
            // Update existing contact
            contact.givenName = trimmedGivenName
            contact.familyName = trimmedFamilyName
            contact.middleName = middleName.nilIfEmpty
            contact.prefix = prefix.nilIfEmpty
            contact.suffix = suffix.nilIfEmpty
            contact.nickname = nickname.nilIfEmpty

            contact.organization = organization.nilIfEmpty
            contact.department = department.nilIfEmpty
            contact.jobTitle = jobTitle.nilIfEmpty

            contact.notes = notes.nilIfEmpty
            contact.updatedAt = .now
        } else {
            // Create new contact
            let newContact = Contact(
                givenName: trimmedGivenName,
                familyName: trimmedFamilyName
            )

            newContact.middleName = middleName.nilIfEmpty
            newContact.prefix = prefix.nilIfEmpty
            newContact.suffix = suffix.nilIfEmpty
            newContact.nickname = nickname.nilIfEmpty

            newContact.organization = organization.nilIfEmpty
            newContact.department = department.nilIfEmpty
            newContact.jobTitle = jobTitle.nilIfEmpty

            newContact.notes = notes.nilIfEmpty

            modelContext.insert(newContact)
        }

        dismiss()
    }
}

// MARK: - Utilities

private extension String {
    var nilIfEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
