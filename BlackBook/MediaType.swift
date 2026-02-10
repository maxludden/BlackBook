//
//  MediaType.swift
//  BlackBook
//
//  Created by Maxwell Ludden on 2/10/26.
//

import Foundation
import SwiftData

enum MediaType: String, Codable {
    case photo
    case video
}

@Model
final class ContactMedia {
    var id: UUID
    var type: MediaType
    var fileURL: URL
    var createdAt: Date
    var isPrimary: Bool

    init(type: MediaType, fileURL: URL, isPrimary: Bool = false) {
        self.id = UUID()
        self.type = type
        self.fileURL = fileURL
        self.createdAt = .now
        self.isPrimary = isPrimary
    }
}
