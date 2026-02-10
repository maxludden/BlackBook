import Foundation
import SwiftData

@Model
final class PostalAddress {
    @Attribute(.unique) var uid: UUID

    var street: String?
    var city: String?
    var state: String?
    var postalCode: String?
    var country: String?
    var label: String?

    // Inverse relationship back to the owning contact
    @Relationship(inverse: \Contact.addresses)
    var contact: Contact?

    init(street: String? = nil,
         city: String? = nil,
         state: String? = nil,
         postalCode: String? = nil,
         country: String? = nil,
         label: String? = nil,
         contact: Contact? = nil) {
        self.uid = UUID()
        self.street = street
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.country = country
        self.label = label
        self.contact = contact
    }
}
