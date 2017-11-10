//
//  GoogleResponses.swift
//  CameraTranslator
//
//  Created by Miroslav Danazhiev on 11/10/17.
//  Copyright © 2017 Miroslav Danazhiev. All rights reserved.
//

import UIKit

struct GoogleResponse: Codable {
    
    struct GoogleData: Codable {
        let translations: [Translations]?
        let languages: [[String: String]]?
        let detections: [[Detections]]?
        enum CodingKeys: String, CodingKey {
            
            case translations = "translations"
            case languages = "languages"
            case detections = "detections"
        }
        
        var supportedLanguages: [String]? {
            var parsedLanguages: [String] = []
            guard let spLanguages = languages else
            { return nil }
            for language in spLanguages {
                if let strLng = language["language"] {
                    parsedLanguages.append(strLng)
                }
            }
            
            return parsedLanguages
        }
        
        var detectedLanguage: String? {
            return detections?.first?.first?.language
        }
    }
    
    let data: GoogleData
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
  
}

struct Detections: Codable {
    
    let language: String?
    
    enum CodingKeys: String, CodingKey {
        case language = "language"
    }
}

struct Translations: Codable {
    
    let translatedText: String?
    enum CodingKeys: String, CodingKey {
        
        case translatedText = "translatedText"
    }
}

