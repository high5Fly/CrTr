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

typealias RequestCompletionHandler = ((_ result: Any?, _ error: Error?) -> Void)!

class GoogleTranslatorManager: NSObject {
    static let sharedInstance = GoogleTranslatorManager()
    static let apiKey = "AIzaSyAipMwdz2rIND7o73TNfxm03W_ccdTlK-k"
    
    func translate(params: GoogleTranslateParams, callback: @escaping (_ translatedText: String?) -> ()) {
        
        if let url = TranslatingText.endpointForParams(params) {
            performRequest(endpoint: url) { (result, error) in
                if let data = result as? Data {
                    let translatedText = TranslatingText.init(data: data)
                    
                    callback(translatedText?.resultText)
                }
            }
        }
    }
    
    func supportedLanguages(callback: @escaping (_ languages: [String]?) -> ()) {
        if let url = Languages.SupportedLanguages.endpointForSupportedLanguages() {
            performRequest(endpoint: url) { (result, error) in
                if let data = result as? Data {
                    let languages = Languages.SupportedLanguages.init(data: data)
                    callback(languages?.supportedLanguages)
                }
            }
        }
    }
    
    func detectLanguageFor(text: String, callback: @escaping (_ translatedText: String?) -> ()) {
        if let url = Languages.DetectingLanguage.endpointForDetectingLangOfText(text: text) {
            performRequest(endpoint: url, complition: { (result, error) in
                if let data = result as? Data {
                    let detectedLanguage = Languages.DetectingLanguage.init(data: data)
                    callback(detectedLanguage?.detectedLanguage)
                }
            })
        }
    }
    
    fileprivate func performRequest(endpoint: URL, complition: RequestCompletionHandler) {
        
        let httprequest = URLSession.shared.dataTask(with: endpoint, completionHandler: { (data, response, error) in
            
            guard error == nil, (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("Something went wrong: \(String(describing: error?.localizedDescription))")
                return
            }
            
            guard let responseData = data else {
                print("Error: did not receive data")
                
                complition(nil, error)
                return
            }
            
            complition(responseData, nil)
        })
        
        httprequest.resume()
    }
    
}

struct TranslatingText: Codable {
    
    var resultText: String?
    init?(data: Data) {
        
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                return nil
            }
            guard let jsonData = json["data"] as? [String : Any],
                let translations = jsonData["translations"] as? [NSDictionary],
                let translation = translations.first as? [String : Any],
                let translatedText = translation["translatedText"] as? String
                else {
                    return nil
            }
            
            resultText = translatedText
            
        } catch {
            print("Serialization failed: \(error.localizedDescription)")
        }
    }
    
    static func endpointForParams(_ params: GoogleTranslateParams) -> URL? {
        guard let urlEncodedText = params.text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            let url = URL(string: "https://www.googleapis.com/language/translate/v2?key=\(GoogleTranslatorManager.apiKey)&q=\(urlEncodedText)&source=\(params.sourceLang)&target=\(params.targetLang)") else {
                return nil
        }
        
        return url
    }
}

struct Languages: Codable {
    
    
    
    
    struct SupportedLanguages: Codable {
    
        var supportedLanguages: [String]
        init?(data: Data) {
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    return nil
                }
                guard let jsonData = json["data"] as? [String : Any],
                    let languages = jsonData["languages"] as? [NSDictionary]
                    else {
                        return nil
                }
                
                var parsedLanguages: [String] = []
                for language in languages {
                    if let strLng = language["language"] as? String {
                        parsedLanguages.append(strLng)
                    }
                }
                
                supportedLanguages = parsedLanguages
                
            } catch {
                print("Serialization failed: \(error.localizedDescription)")
                return nil
            }
        }
        
        static func endpointForSupportedLanguages() -> URL? {
            guard let url = URL(string: "https://translation.googleapis.com/language/translate/v2/languages?key=\(GoogleTranslatorManager.apiKey)") else {
                return nil
            }
            return url
        }
    }
    
    struct DetectingLanguage {
        var detectedLanguage: String?
        init?(data: Data) {
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    return nil
                }
                guard let jsonData = json["data"] as? [String : Any],
                    let detections = jsonData["detections"] as? [Any]
                    else {
                        return nil
                }
                let language = detections.first as? [Any]
                if let detected = language?.first as? [String: Any] {
                    let strlng = detected["language"] as? String
                    
                    detectedLanguage = strlng
                }
                
            } catch {
                print("Serialization failed: \(error.localizedDescription)")
                return nil
            }
        }
        
        static func endpointForDetectingLangOfText(text: String) -> URL? {
            
            guard let urlEncodedText = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                return nil
            }
            
            guard let url = URL(string: "https://translation.googleapis.com/language/translate/v2/detect?key=\(GoogleTranslatorManager.apiKey)&q=\(urlEncodedText)") else {
                return nil
            }
            return url
        }
    }
}

