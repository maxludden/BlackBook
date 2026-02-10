import SwiftUI
import SwiftData

struct ContactListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: [
        SortDescriptor(\Contact.familyName),
        SortDescriptor(\Contact.givenName)
    ])
    private var contacts: [Contact]

    @Binding var selection: Set<Contact.ID>
    let onAddContact: () -> Void

    @Environment(\.editMode) private var editMode

    @State private var pendingDeleteOffsets: IndexSet? = nil
    @State private var showDeleteConfirmation: Bool = false

    private var isEditing: Bool { editMode?.wrappedValue.isEditing == true }
    
    private func isSelected(_ contact: Contact) -> Bool {
        selection.contains(contact.id)
    }
    
    private func select(_ contact: Contact) {
        selection.insert(contact.id)
    }
    
    private func deselect(_ contact: Contact) {
        selection.remove(contact.id)
    }

    private var selectedContacts: [Contact] {
        contacts.filter { contact in
            isSelected(contact)
        }
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(contacts) { contact in
                ContactRowView(contact: contact)
                    .tag(contact.id)
            }
            .onDelete { offsets in
                pendingDeleteOffsets = offsets
                showDeleteConfirmation = true
            }
        }
        .navigationTitle("Contacts")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: onAddContact) {
                    Label("Add Contact", systemImage: "plus")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                if isEditing && !selection.isEmpty {
                    Button(role: .destructive, action: handleDeleteCommand) {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            ToolbarItem(placement: .bottomBar) {
                if isEditing {
                    Button(role: .destructive, action: confirmMultiDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                    .disabled(selection.isEmpty)
                }
            }
            ToolbarItem(placement: .automatic) {
                EditButton()
            }
        }
        .overlay {
            if contacts.isEmpty {
                ContentUnavailableView(
                    "No Contacts",
                    systemImage: "person.crop.circle.badge.plus",
                    description: Text("Add your first contact to get started.")
                )
            }
        }
        .alert("Delete Contact(s)?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                pendingDeleteOffsets = nil
            }
            Button("Delete", role: .destructive) {
                if let offsets = pendingDeleteOffsets {
                    deleteContacts(offsets)
                }
                pendingDeleteOffsets = nil
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private func handleDeleteCommand() {
        if !selection.isEmpty {
            confirmMultiDelete()
        } else {
            // No selection: present alert but nothing to delete
            showDeleteConfirmation = true
            pendingDeleteOffsets = IndexSet()
        }
    }

    private func confirmMultiDelete() {
        let toDelete = selectedContacts
        for contact in toDelete {
            modelContext.delete(contact)
        }
        selection.removeAll()
    }

    private func deleteContacts(_ offsets: IndexSet) {
        for index in offsets {
            let contact = contacts[index]
            if isSelected(contact) {
                deselect(contact)
            }
            modelContext.delete(contact)
        }
    }
}

// MARK: - Row View

struct ContactRowView: View {
    let contact: Contact

    var body: some View {
        HStack(spacing: 12) {
            // Placeholder for primary photo later
            Circle()
                .fill(.gray.opacity(0.3))
                .frame(width: 36, height: 36)

            VStack(alignment: .leading) {
                Text("\(contact.givenName) \(contact.familyName)")
                    .font(.body)
                if let organization = contact.organization, !organization.isEmpty {
                    Text(organization)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

