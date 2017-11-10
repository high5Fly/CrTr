//
//  Constants.swift
//  CameraTranslator
//
//  Created by Miroslav Danazhiev on 11/10/17.
//  Copyright © 2017 Miroslav Danazhiev. All rights reserved.
//

import UIKit

struct Constants {
    struct API {
        struct HTTPMethod {
            let POST = "POST"
            let GET = "GET"
        }
        
        struct URL {
            let translatingURL = "https://translation.googleapis.com/language/translate/v2?"
            let suppLanguagesURL = "https://translation.googleapis.com/language/translate/v2/languages?"
            let detectingLanguageURL = "https://translation.googleapis.com/language/translate/v2/detect?"
            let textExtractionURL = "https://vision.googleapis.com/v1/images:annotate?"
            
            struct URLsubKeys {
            
                let q = "q"
                let target = "target"
                let key = "key"
                
            }
        }
        struct TextExtracting {
            struct FeatureType {
                let textDetection = "TEXT_DETECTION"
                let labelDetection = "DOCUMENT_TEXT_DETECTION"
            }
        }
        let apiKey = "AIzaSyAipMwdz2rIND7o73TNfxm03W_ccdTlK-k"
    }
}
