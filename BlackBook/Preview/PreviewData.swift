import SwiftData
import Foundation


#if DEBUG

enum PreviewData {

    // MARK: - Containers

    static func emptyContainer() -> ModelContainer {
        BlackBookApp.previewContainer
    }

    static func containerWithDenseContact() -> ModelContainer {
        let container = BlackBookApp.previewContainer
        let context = container.mainContext
        _ = denseContact(in: context)
        return container
    }

    static func containerWithPathologicalContact() -> ModelContainer {
        let container = BlackBookApp.previewContainer
        let context = container.mainContext
        _ = pathologicalContact(in: context)
        return container
    }

    // MARK: - Contacts

    /// A realistic, fully-populated contact
    static func denseContact(in context: ModelContext) -> Contact {
        let contact = Contact(
            givenName: "Ben",
            familyName: "Dover"
        )

        contact.middleName = "Michael"
        contact.prefix = "Sir"
        contact.nickname = "Benny"

        contact.organization = "Pup Group"
        contact.department = "Eboard"
        contact.jobTitle = "President"

        contact.notes =
        """
        President of the Pup Group.
        """

        // Phone numbers
        contact.phoneNumbers.append(
            PhoneNumber(number: "+18008888888", type: .work)
        )
        contact.phoneNumbers.append(
            PhoneNumber(number: "+15854004000", type: .mobile)
        )

        // Emails
        contact.emails.append(
            EmailAddress(address: "bdover@ub.edu", type: .work)
        )
        contact.emails.append(
            EmailAddress(address: "bendover@gmail.com", type: .personal)
        )

        // URLs
        contact.urls.append(
            ContactURL(urlString: "https://github.com/bendover", type: UrlType.github, label: "GitHub")
        )

        // Addresses
        contact.addresses.append(
            PostalAddress(
                street: "50 Gibbs St",
                city: "Rochester",
                state: "New York",
                postalCode: "14605",
                country: "United States",
                label: "Home"
            )
        )

        context.insert(contact)
        return contact
    }

    /// A deliberately hostile edge-case contact
    static func pathologicalContact(in context: ModelContext) -> Contact {
        let contact = Contact(
            givenName: "ANameThatIsSoUnreasonablyLongItWillAbsolutelyBreakAnyNaiveLayout",
            familyName: "AnotherExcessivelyVerboseSurnameDesignedToCausePain"
        )

        contact.nickname =
        "🚨🔥💀 Extremely Long Nickname With Emojis, Unicode, and Absolutely No Restraint 💀🔥🚨"

        contact.organization =
        "A Company With A Name So Long It Probably Violates Several Design Guidelines And Common Sense"

        contact.jobTitle =
        "Senior Principal Distinguished Lead Executive Vice Assistant to the Acting Interim Director"

        contact.notes =
        String(repeating: "This is a pathological note. ", count: 40)

        // One absurd phone number
        contact.phoneNumbers.append(
            PhoneNumber(number: "+123456789012345678901234567890", type: .other)
        )

        // Broken-looking email
        contact.emails.append(
            EmailAddress(address: "this-is-not-a-real-email-address@", type: .other)
        )

        context.insert(contact)
        return contact
    }
}

#endif

