import Foundation
import SwiftData

enum UrlType: String, Codable {
    case homepage, work, github, twitter, instagram, facebook, other
}

@Model
final class ContactURL {
    @Attribute(.unique) var uid: UUID

    var urlString: String
    var type: UrlType = UrlType.other
    var label: String?

    // Inverse relationship back to the owning contact
    @Relationship(inverse: \Contact.urls)
    var contact: Contact?

    var url: URL

    init(urlString: String, type: UrlType = .other, label: String? = nil, contact: Contact? = nil) {
        self.uid = UUID()
        self.urlString = urlString
        self.type = type
        self.label = label
        self.contact = contact
    }
}
extension ContactURL {
    convenience init(url: URL, type: UrlType = .other, label: String? = nil, contact: Contact? = nil) {
        self.init(urlString: url.absoluteString, type: type, label: label, contact: contact)
    }
}

