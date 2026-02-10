//
//  ApplicationSupport.swift
//  BlackBook
//
//  Created by Maxwell Ludden on 2/10/26.
//

import Foundation
import SwiftData
import UIKit


func applicationSupportDirectory() throws -> URL {
    let url = try FileManager.default.url(
        for: .applicationSupportDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
    )
    return url
}

func contactsMediaRoot() throws -> URL {
    let base = try applicationSupportDirectory()
    let contactsDir = base.appendingPathComponent("Contacts", isDirectory: true)

    if !FileManager.default.fileExists(atPath: contactsDir.path) {
        try FileManager.default.createDirectory(
            at: contactsDir,
            withIntermediateDirectories: true
        )
    }

    return contactsDir
}

func directoryForContact(id: UUID) throws -> URL {
    let root = try contactsMediaRoot()
    let contactDir = root.appendingPathComponent(id.uuidString, isDirectory: true)

    if !FileManager.default.fileExists(atPath: contactDir.path) {
        try FileManager.default.createDirectory(
            at: contactDir,
            withIntermediateDirectories: true
        )
    }

    return contactDir
}

func savePhoto(
    _ image: UIImage,
    to contactID: UUID
) throws -> URL {
    let dir = try directoryForContact(id: contactID)
    let filename = "photo-\(UUID().uuidString).heic"
    let url = dir.appendingPathComponent(filename)

    guard let data = image.heicData() else {
        throw CocoaError(.fileWriteUnknown)
    }

    try data.write(to: url, options: [.atomic])
    return url
}

func saveVideo(
    from sourceURL: URL,
    to contactID: UUID
) throws -> URL {
    let dir = try directoryForContact(id: contactID)
    let destination = dir.appendingPathComponent(sourceURL.lastPathComponent)

    try FileManager.default.copyItem(
        at: sourceURL,
        to: destination
    )

    return destination
}

func saveFile(
    from sourceURL: URL,
    to contactID: UUID
) throws -> URL {
    let dir = try directoryForContact(id: contactID)
    let destination = dir.appendingPathComponent(sourceURL.lastPathComponent)

    try FileManager.default.copyItem(
        at: sourceURL,
        to: destination
    )

    return destination
}

func deleteContactMedia(id: UUID) {
    do {
        let dir = try directoryForContact(id: id)
        try FileManager.default.removeItem(at: dir)
    } catch {
        // Log, but don’t crash
    }
}
