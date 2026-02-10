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
