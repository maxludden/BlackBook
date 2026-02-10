//
//  MediaType.swift
//  BlackBook
//
//  Created by Maxwell Ludden on 2/10/26.
//

import Foundation
import SwiftData
import UIKit

enum MediaType: String, Codable {
    case photo
    case video
    case file
}

@Model
final class ContactMedia {
    @Attribute(.unique) var uid: UUID
    var type: MediaType
    var fileURL: URL
    var createdAt: Date
    var isPrimary: Bool

    // Inverse relationship back to the owning contact
    @Relationship(inverse: \Contact.mediaItems)
    var contact: Contact?
    
    init(type: MediaType, fileURL: URL, isPrimary: Bool = false, contact: Contact? = nil) {
        self.uid = UUID()
        self.type = type
        self.fileURL = fileURL
        self.createdAt = .now
        self.isPrimary = isPrimary
        self.contact = contact
    }
}

extension ContactMedia {
    /// Creates a photo media item by saving the given image to disk under the contact's media directory,
    /// appending the media to the contact, and optionally marking it as primary.
    /// - Parameters:
    ///   - image: The UIImage to save as HEIC (falls back to JPEG if HEIC unavailable).
    ///   - contact: The owning contact.
    ///   - isPrimary: Whether this media should become the primary item for the contact.
    /// - Returns: The created ContactMedia instance.
    /// - Throws: Errors from the file system while saving the image.
    static func photo(from image: UIImage, for contact: Contact, isPrimary: Bool = false) throws -> ContactMedia {
        let url = try savePhoto(image, to: contact.uid)
        let media = ContactMedia(type: .photo, fileURL: url, isPrimary: false, contact: nil)
        contact.mediaItems.append(media)
        if isPrimary {
            media.markAsPrimary()
        }
        return media
    }
    /// Creates a video media item by copying the video file into the contact's media directory,
    /// appending the media to the contact, and optionally marking it as primary.
    /// - Parameters:
    ///   - sourceURL: The file URL of the video to copy.
    ///   - contact: The owning contact.
    ///   - isPrimary: Whether this media should become the primary item for the contact.
    /// - Returns: The created ContactMedia instance.
    /// - Throws: Errors from the file system while copying the video.
    static func video(from sourceURL: URL, for contact: Contact, isPrimary: Bool = false) throws -> ContactMedia {
        let destination = try saveVideo(from: sourceURL, to: contact.uid)
        let media = ContactMedia(type: .video, fileURL: destination, isPrimary: false, contact: nil)
        contact.mediaItems.append(media)
        if isPrimary {
            media.markAsPrimary()
        }
        return media
    }
    
    /// Creates a video media item by compying the file into the contact's media directory.
    /// appending the media to the contact, and optionally marking it as primary.
    /// - Parameters:
    ///   - sourceURL: The file URL of the the file to copy.
    ///   - contact: The owning contact.
    ///   - isPrimary:Whether this file should become the primary item for the contact.
    /// - Returns: The created ContactMedia instance.
    /// - Throws: Errors from the file system while copying the video.
    static func file(from sourceURL: URL, for contact: Contact, isPrimary: Bool = false) throws -> ContactMedia {
        let destination = try save(from: sourceURL, to: contact.uid)
        let media = ContactMedia(type: .file, fileURL: destination, isPrimary: false, contact: nil)
        contact.mediaItems.append(media)
        if isPrimary {
            media.markAsPrimary()
        }
        return media
    }

    /// Marks this media as the sole primary media for its contact, clearing the flag on siblings.
    func markAsPrimary() {
        guard let contact else {
            self.isPrimary = true
            return
        }
        for item in contact.mediaItems {
            item.isPrimary = (item === self)
        }
    }
}

