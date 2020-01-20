//
//  Template.swift
//  SimplePhotoTemplate
//
//  Created by Shawn Wu on 1/19/20.
//  Copyright © 2020 Shawn Wu. All rights reserved.
//

import UIKit

public struct Templates: Codable {
    public let templates: [Template]
    enum CodingKeys: String, CodingKey {
        case templates = "templates"
    }
}

public struct Template: Codable {
    public let name: String
    public let background: String
    public let texts: [Text]
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case texts = "texts"
        case background = "background"
    }
}

public struct Text: Codable {
    public let font: String
    public let size: Int
    public let color: String
    
    public init(font: String, size: Int, color: String) {
        self.font = font
        self.size = size
        self.color = color
    }
    
    enum CodingKeys: String, CodingKey {
        case font = "font"
        case size = "size"
        case color = "color"
    }
}
