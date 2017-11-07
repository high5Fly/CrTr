//
//  GoogleTranslatorManager.swift
//  CameraTranslator
//
//  Created by Miroslav Danazhiev on 11/7/17.
//  Copyright © 2017 Miroslav Danazhiev. All rights reserved.
//

import UIKit

public struct GoogleTranslateParams {
    
    var sourceLang: String
    var targetLang: String
    var text: String
}

class GoogleTranslatorManager: NSObject {
    static let sharedInstance = GoogleTranslatorManager()
    static let apiKey = "AIzaSyAipMwdz2rIND7o73TNfxm03W_ccdTlK-k"
    
    open func translate(params: GoogleTranslateParams, callback: @escaping (_ translatedText: String) -> ()) {
        
        guard
            let urlEncodedText = params.text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            let url = URL(string: "https://www.googleapis.com/language/translate/v2?key=\(GoogleTranslatorManager.apiKey)&q=\(urlEncodedText)&source=\(params.sourceLang)&target=\(params.targetLang)") else {
                return
        }
        
        let httprequest = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            
            guard error == nil, (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("Something went wrong: \(String(describing: error?.localizedDescription))")
                return
            }
            
            do {
                guard
                    let data = data,
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary,
                    let jsonData = json["data"] as? [String : Any],
                    let translations = jsonData["translations"] as? [NSDictionary],
                    let translation = translations.first  as? [String : Any],
                    let translatedText = translation["translatedText"] as? String
                    else {
                        return
                }
                callback(translatedText)
                
            } catch {
                print("Serialization failed: \(error.localizedDescription)")
            }
        })
        
        httprequest.resume()
    }
}
