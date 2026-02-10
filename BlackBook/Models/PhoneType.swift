//
//  PhoneType.swift
//  BlackBook
//
//  Created by Maxwell Ludden on 2/10/26.
//

import Foundation
import SwiftData

enum PhoneType: String, Codable {
    case mobile, home, work, fax, pager, other
}

@Model
final class PhoneNumber {
    var number: String
    var type: PhoneType
    var label: String?

    init(number: String, type: PhoneType, label: String? = nil) {
        self.number = number
        self.type = type
        self.label = label
    }
}
