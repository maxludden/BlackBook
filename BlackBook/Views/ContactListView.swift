import SwiftUI
import SwiftData
import PhotosUI
import UIKit

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
    @State private var pendingDeleteContactIDs: Set<Contact.ID> = []
    @State private var showDeleteConfirmation: Bool = false
    @State private var searchText: String = ""

    // TODO: Wire up media pickers to create ContactMedia instances
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var videoPickerItem: PhotosPickerItem?

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
    
    private func selectedContact() -> Contact? {
        guard selection.count == 1, let id = selection.first else { return nil }
        return contacts.first { $0.persistentModelID == id }
    }

    private var selectedContacts: [Contact] {
        contacts.filter { contact in
            isSelected(contact)
        }
    }

    private var filteredContacts: [Contact] {
        let term = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return contacts }
        let lower = term.lowercased()
        return contacts.filter { contact in
            contact.givenName.lowercased().contains(lower)
            || contact.familyName.lowercased().contains(lower)
            || (contact.organization?.lowercased().contains(lower) ?? false)
        }
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(filteredContacts) { contact in
                ContactRowView(contact: contact)
                    .tag(contact.id)
            }
            .onDelete { offsets in
                pendingDeleteOffsets = offsets
                showDeleteConfirmation = true
            }
        }
        .navigationTitle("Contacts")
        .searchable(text: $searchText, prompt: "Search Contacts")
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
            // TODO: Enable and implement media pickers (photo/video)
            ToolbarItem(placement: .primaryAction) {
                PhotosPicker(selection: $photoPickerItem, matching: .images) {
                    Label("Add Photo", systemImage: "photo.on.rectangle")
                }
                .disabled(selection.count != 1)
            }
            ToolbarItem(placement: .primaryAction) {
                PhotosPicker(selection: $videoPickerItem, matching: .videos) {
                    Label("Add Video", systemImage: "video.badge.plus")
                }
                .disabled(selection.count != 1)
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
        .onChange(of: photoPickerItem) { _, newValue in
            guard let item = newValue else { return }
            Task { @MainActor in
                guard let contact = selectedContact() else { return }
                do {
                    if let data = try await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        _ = try ContactMedia.photo(
                            from: image,
                            for: contact,
                            isPrimary: contact.mediaItems.isEmpty
                        )
                        try modelContext.save()
                    }
                } catch {
                    // You can add user-facing error handling here if desired
                }
                photoPickerItem = nil
            }
        }
        .onChange(of: videoPickerItem) { _, newValue in
            guard let item = newValue else { return }
            Task { @MainActor in
                guard let contact = selectedContact() else { return }
                do {
                    if let url = try await item.loadTransferable(type: URL.self) {
                        _ = try ContactMedia.video(
                            from: url,
                            for: contact,
                            isPrimary: contact.mediaItems.isEmpty
                        )
                        try modelContext.save()
                    }
                } catch {
                    // You can add user-facing error handling here if desired
                }
                videoPickerItem = nil
            }
        }
        .overlay {
            if contacts.isEmpty {
                ContentUnavailableView(
                    "No Contacts",
                    systemImage: "person.crop.circle.badge.plus",
                    description: Text("Add your first contact to get started.")
                )
            } else if filteredContacts.isEmpty && !searchText.isEmpty {
                ContentUnavailableView(
                    "No Results",
                    systemImage: "magnifyingglass",
                    description: Text("No contacts match \"\(searchText)\".")
                )
            }
        }
        .alert("Delete Contact(s)?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                pendingDeleteOffsets = nil
                pendingDeleteContactIDs.removeAll()
            }
            Button("Delete", role: .destructive) {
                if !pendingDeleteContactIDs.isEmpty {
                    deleteContacts(withIDs: pendingDeleteContactIDs)
                } else if let offsets = pendingDeleteOffsets {
                    deleteContacts(offsets)
                }
                pendingDeleteOffsets = nil
                pendingDeleteContactIDs.removeAll()
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    private func handleDeleteCommand() {
        guard !selection.isEmpty else { return }
        confirmMultiDelete()
    }

    private func confirmMultiDelete() {
        pendingDeleteContactIDs = Set(selectedContacts.map(\.id))
        showDeleteConfirmation = true
    }

    private func deleteContacts(_ offsets: IndexSet) {
        let contactsToDelete = offsets.map { filteredContacts[$0] }
        deleteContacts(contactsToDelete)
    }

    private func deleteContacts(withIDs ids: Set<Contact.ID>) {
        let contactsToDelete = contacts.filter { ids.contains($0.id) }
        deleteContacts(contactsToDelete)
    }

    private func deleteContacts(_ contactsToDelete: [Contact]) {
        for contact in contactsToDelete {
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
            ContactThumbnailView(contact: contact)

            VStack(alignment: .leading) {
                Text(contact.displayName)
                    .font(.body)
                if let organization = contact.organization, !organization.isEmpty {
                    Text(organization)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // TODO: Enable context menu actions for media when implemented
            // .contextMenu {
            //     Button("Make Primary Photo") { }
            //         .disabled(true)
            //     Button("Add Media…") { }
            //         .disabled(true)
            // }
        }
    }
}

private struct ContactThumbnailView: View {
    let contact: Contact
    var body: some View {
        // TODO: Display primary photo thumbnail if available; fallback to initials or placeholder
        // When implemented: load image from contact.mediaItems.first(where: { $0.isPrimary && $0.type == .photo })
        Circle()
            .fill(.gray.opacity(0.3))
            .frame(width: 36, height: 36)
    }
}

