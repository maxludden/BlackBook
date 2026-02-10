import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedContact: Contact?
    @State private var showingNewContact = false

    var body: some View {
        NavigationSplitView {
            ContactListView(
                selection: Binding<Set<Contact.ID>>(
                    get: {
                        if let contact = selectedContact {
                            return [contact.id]
                        } else {
                            return []
                        }
                    },
                    set: { newSelection in
                        // If selection is cleared, clear the selected contact
                        guard let first = newSelection.first else {
                            selectedContact = nil
                            return
                        }
                        // If the currently selected contact already matches, keep it
                        if let current = selectedContact, current.id == first {
                            return
                        }
                        // Fetch the Contact from SwiftData using the persistent identifier
                        do {
                            var descriptor = FetchDescriptor<Contact>()
                            descriptor.predicate = #Predicate { $0.persistentModelID == first }
                            descriptor.fetchLimit = 1
                            if let fetched = try modelContext.fetch(descriptor).first {
                                selectedContact = fetched
                            } else {
                                selectedContact = nil
                            }
                        } catch {
                            // On fetch failure, clear selection
                            selectedContact = nil
                        }
                    }
                ),
                onAddContact: {
                    showingNewContact = true
                }
            )
        } detail: {
            if let contact = selectedContact {
                ContactDetailView(contact: contact)
            } else {
                ContentUnavailableView(
                    "No Contact Selected",
                    systemImage: "person.crop.circle",
                    description: Text("Select a contact to view details")
                )
            }
        }
        .sheet(isPresented: $showingNewContact) {
            ContactEditorView()
        }
    }
}

