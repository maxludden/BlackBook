import Foundation
import Contacts

struct VCardService {
    
    enum VCardServiceError: Error {
        case invalidData
    }
    
    /// Export an array of values to vCard Data using a mapper that produces CNMutableContact
    func export<T>(_ items: [T], map: (T) -> CNMutableContact) throws -> Data {
        let cnContacts = items.map { map($0) as CNContact }
        do {
            return try CNContactVCardSerialization.data(with: cnContacts)
        } catch {
            throw VCardServiceError.invalidData
        }
    }
    
    /// Export CNContacts directly to vCard Data
    func export(contacts: [CNContact]) throws -> Data {
        do {
            return try CNContactVCardSerialization.data(with: contacts)
        } catch {
            throw VCardServiceError.invalidData
        }
    }
    
    /// Import vCard Data into an array of values using a mapper from CNContact
    func `import`<R>(data: Data, map: (CNContact) -> R) throws -> [R] {
        let cnContacts: [CNContact]
        do {
            cnContacts = try CNContactVCardSerialization.contacts(with: data)
        } catch {
            throw VCardServiceError.invalidData
        }
        return cnContacts.map { map($0) }
    }
    
    /// Import vCard Data and return CNContacts directly
    func `import`(data: Data) throws -> [CNContact] {
        let cnContacts: [CNContact]
        do {
            cnContacts = try CNContactVCardSerialization.contacts(with: data)
        } catch {
            throw VCardServiceError.invalidData
        }
        return cnContacts
    }
    
    static let iso8601DateFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withFullDate]
        return f
    }()
}



extension VCardService {

    @MainActor
    static func export(_ contacts: [ParsedContact]) throws -> Data {
        let cnContacts = contacts.map(makeCNContact)
        return try CNContactVCardSerialization.data(with: cnContacts)
    }

    @MainActor
    private static func makeCNContact(_ parsed: ParsedContact) -> CNContact {
        let contact = CNMutableContact()

        contact.givenName = parsed.givenName
        contact.familyName = parsed.familyName
        contact.organizationName = parsed.organization ?? ""
        contact.jobTitle = parsed.jobTitle ?? ""

        contact.emailAddresses = parsed.emails.map {
            CNLabeledValue(
                label: $0.label,
                value: NSString(string: $0.value)
            )
        }

        contact.phoneNumbers = parsed.phoneNumbers.map {
            CNLabeledValue(
                label: $0.label,
                value: CNPhoneNumber(stringValue: $0.value)
            )
        }

        contact.urlAddresses = parsed.urls.map {
            CNLabeledValue(
                label: $0.label,
                value: NSString(string: $0.value)
            )
        }

        contact.postalAddresses = parsed.postalAddresses.map {
            let addr = CNMutablePostalAddress()
            addr.street = $0.street ?? ""
            addr.city = $0.city ?? ""
            addr.state = $0.state ?? ""
            addr.postalCode = $0.postalCode ?? ""
            addr.country = $0.country ?? ""

            return CNLabeledValue(label: $0.label, value: addr)
        }

        contact.dates = parsed.dates.map {
            let comps = Calendar.current.dateComponents([.year, .month, .day], from: $0.date)
            return CNLabeledValue(
                label: $0.label,
                value: comps as NSDateComponents
            )
        }

        return contact.copy() as! CNContact
    }
}
