import Foundation
import SwiftData

enum EmailType: String, Codable {
    case personal, work, other
}

@Model
final class EmailAddress {
    @Attribute(.unique) var uid: UUID
    var address: String
    var type: EmailType
    var label: String?

    // Inverse relationship back to the owning contact
    @Relationship(inverse: \Contact.emails)
    var contact: Contact?

    init(address: String, type: EmailType, label: String? = nil, contact: Contact? = nil) {
        self.uid = UUID()
        self.address = address
        self.label = label
        self.type = type
        self.contact = contact
    }
}
