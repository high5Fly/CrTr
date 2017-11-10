//
//  GoogleTranslatorManager.swift
//  CameraTranslator
//
//  Created by Miroslav Danazhiev on 11/7/17.
//  Copyright © 2017 Miroslav Danazhiev. All rights reserved.
//

import UIKit

public struct GoogleParams {
    
    var sourceLang: String
    var targetLang: String
    var text: String
    var image: String?
}

typealias RequestCompletionHandler = ((_ result: Any?, _ error: Error?) -> Void)!

class GoogleManager: NSObject {
    static let sharedInstance = GoogleManager()
    static let apiKey = "AIzaSyAipMwdz2rIND7o73TNfxm03W_ccdTlK-k"
    fileprivate let decoder = JSONDecoder()
    func translate(params: GoogleParams, callback: @escaping (_ translatedText: String?) -> ()) {
        
        if let url = GoogleManager.endpointForParams(params) {
            performRequest(endpoint: url) { [weak self] (result, error) in
                if let data = result as? Data {
                    
                    do {
                        let response = try self?.decoder.decode(GoogleResponse.self, from: data)
                        callback(response?.data.translations?.first?.translatedText)
                    } catch {
                        print(error)
                        callback(nil)
                    }
                }
            }
        }
    }
    
    func supportedLanguages(callback: @escaping (_ languages: [String]?) -> ()) {
        if let url = GoogleManager.endpointForSupportedLanguages() {
            performRequest(endpoint: url) { [weak self] (result, error) in
                if let data = result as? Data {
                    
                    do {
                        let response = try self?.decoder.decode(GoogleResponse.self, from: data)
                        callback(response?.data.supportedLanguages)
                    } catch {
                        print(error)
                        callback(nil)
                    }
                }
            }
        }
    }
    
    func detectLanguageFor(text: String, callback: @escaping (_ translatedText: String?) -> ()) {
        if let url = GoogleManager.endpointForDetectingLangOfText(text: text) {
            performRequest(endpoint: url, complition: { [weak self] (result, error) in
                if let data = result as? Data {
                    
                    do {
                        let response = try self?.decoder.decode(GoogleResponse.self, from: data)
                        callback(response?.data.detectedLanguage)
                    } catch {
                        print(error)
                        callback(nil)
                    }
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
    
    fileprivate createRequest(params: GoogleParams) {
    
    }
    
}

private extension GoogleManager {
    static func endpointForParams(_ params: GoogleParams) -> URL? {
        guard let urlEncodedText = params.text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            let url = URL(string: "https://www.googleapis.com/language/translate/v2?key=\(GoogleManager.apiKey)&q=\(urlEncodedText)&source=\(params.sourceLang)&target=\(params.targetLang)") else {
                return nil
        }
        
        return url
    }
    
    static func endpointForSupportedLanguages() -> URL? {
        guard let url = URL(string: "https://translation.googleapis.com/language/translate/v2/languages?key=\(GoogleManager.apiKey)") else {
            return nil
        }
        return url
    }
    
    static func endpointForDetectingLangOfText(text: String) -> URL? {
        
        guard let urlEncodedText = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return nil
        }
        
        guard let url = URL(string: "https://translation.googleapis.com/language/translate/v2/detect?key=\(GoogleManager.apiKey)&q=\(urlEncodedText)") else {
            return nil
        }
        return url
    }
}

