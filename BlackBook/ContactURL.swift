import Foundation
import SwiftData

@Model
final class ContactURL {
    @Attribute(.unique) var uid: UUID

    var urlString: String
    var label: String?

    // Inverse relationship back to the owning contact
    @Relationship(inverse: \Contact.urls)
    var contact: Contact?

    var url: URL? { URL(string: urlString) }

    init(urlString: String, label: String? = nil, contact: Contact? = nil) {
        self.uid = UUID()
        self.urlString = urlString
        self.label = label
        self.contact = contact
    }
}
