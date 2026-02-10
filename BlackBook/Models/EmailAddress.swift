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
extension EmailAddress {
    // Unlabeled convenience initializer for brevity in previews/builders
    convenience init(_ address: String, type: EmailType = .other, label: String? = nil, contact: Contact? = nil) {
        self.init(address: address, type: type, label: label, contact: contact)
    }

    // Convenience factories for common types
    static func personal(_ address: String, label: String? = nil, contact: Contact? = nil) -> EmailAddress {
        EmailAddress(address: address, type: .personal, label: label, contact: contact)
    }

    static func work(_ address: String, label: String? = nil, contact: Contact? = nil) -> EmailAddress {
        EmailAddress(address: address, type: .work, label: label, contact: contact)
    }
}

