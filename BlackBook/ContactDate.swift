import Foundation
import SwiftData

@Model
final class ContactDate {
    @Attribute(.unique) var uid: UUID

    var date: Date
    var label: String?

    // Inverse relationship back to the owning contact
    @Relationship(inverse: \Contact.dates)
    var contact: Contact?

    init(date: Date, label: String? = nil, contact: Contact? = nil) {
        self.uid = UUID()
        self.date = date
        self.label = label
        self.contact = contact
    }
}
