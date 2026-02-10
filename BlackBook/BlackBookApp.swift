//
//  BlackBookApp.swift
//  BlackBook
//
//  Created by Maxwell Ludden on 2/10/26.
//

import SwiftUI
import SwiftData

@main
struct BlackBookApp: App {

    // MARK: - App Container (real data)

    private var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Contact.self,
            PhoneNumber.self,
            EmailAddress.self,
            PostalAddress.self,
            ContactURL.self,
            ContactDate.self,
            ContactMedia.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    // MARK: - Preview Container (DEBUG only)

    #if DEBUG
    static let previewContainer: ModelContainer = {
        let schema = Schema([
            Contact.self,
            PhoneNumber.self,
            EmailAddress.self,
            PostalAddress.self,
            ContactURL.self,
            ContactDate.self,
            ContactMedia.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        return try! ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }()
    #endif

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
